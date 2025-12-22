# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account Lockout Integration', type: :request do
  let!(:user) do
    User.create!(
      mobile_number: '+989120000999',
      password: 'TestPassword123',
      password_confirmation: 'TestPassword123',
      account_status: 'active'
    )
  end

  describe 'Account lockout after failed login attempts' do
    it 'locks account after 5 failed login attempts' do
      # Attempt 5 failed logins
      5.times do
        post '/api/v1/auth/login', params: {
          mobile_number: '+989120000999',
          password: 'WrongPassword'
        }
        expect(response).to have_http_status(:unauthorized)
      end

      # Reload user to get updated state
      user.reload

      # Verify account is locked
      expect(user.locked?).to be true
      expect(user.failed_login_attempts).to eq(5)
      expect(user.locked_until).not_to be_nil
      expect(user.locked_until).to be > Time.current

      # 6th attempt should fail with locked message
      post '/api/v1/auth/login', params: {
        mobile_number: '+989120000999',
        password: 'TestPassword123'
      }
      expect(response).to have_http_status(:forbidden)
      response_body = JSON.parse(response.body)
      expect(response_body['error']).to match(/locked|blocked/i)
    end

    it 'unlocks account after 15 minutes' do
      # Lock the account by setting locked_until to 14 minutes ago
      user.update!(
        failed_login_attempts: 5,
        locked_at: 16.minutes.ago,
        locked_until: 1.minute.ago,
        account_status: 'active'
      )

      # Attempt login after lockout period
      post '/api/v1/auth/login', params: {
        mobile_number: '+989120000999',
        password: 'TestPassword123'
      }

      # Should succeed
      expect(response).to have_http_status(:ok)
      response_body = JSON.parse(response.body)
      expect(response_body.dig('data', 'token')).not_to be_nil

      # Verify lockout was reset
      user.reload
      expect(user.failed_login_attempts).to eq(0)
      # Note: locked_at may still be set but user should be able to login
      expect(user.locked?).to be false
    end

    it 'keeps account locked within 15 minute window' do
      # Lock the account with locked_until in the future
      user.update!(
        failed_login_attempts: 5,
        locked_at: 5.minutes.ago,
        locked_until: 10.minutes.from_now,
        account_status: 'active'
      )

      # Attempt login during lockout period
      post '/api/v1/auth/login', params: {
        mobile_number: '+989120000999',
        password: 'TestPassword123'
      }

      # Should fail with locked message
      expect(response).to have_http_status(:forbidden)
      response_body = JSON.parse(response.body)
      expect(response_body['error']).to match(/locked|blocked/i)

      # Verify lockout state unchanged
      user.reload
      expect(user.failed_login_attempts).to eq(5)
      expect(user.locked?).to be true
    end

    it 'resets failed attempts counter on successful login' do
      # Set some failed attempts
      user.update!(failed_login_attempts: 3)

      # Successful login
      post '/api/v1/auth/login', params: {
        mobile_number: '+989120000999',
        password: 'TestPassword123'
      }

      expect(response).to have_http_status(:ok)

      # Verify counter reset
      user.reload
      expect(user.failed_login_attempts).to eq(0)
    end
  end
end
