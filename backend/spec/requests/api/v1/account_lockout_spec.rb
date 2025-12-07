# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account Lockout', type: :request do
  let(:mobile_number) { '09123456789' }
  let(:password) { 'Password123' }
  let(:user) { User.create!(mobile_number:, password:, password_confirmation: password, account_status: :active) }

  describe 'POST /api/v1/auth/login' do
    context 'with repeated failed login attempts' do
      it 'locks account after 5 failed attempts' do
        # First 4 failed attempts - should not lock
        4.times do
          post '/api/v1/auth/login', params: { 
            auth: { mobile_number: user.mobile_number, password: 'WrongPassword' } 
          }
          expect(response).to have_http_status(:unauthorized)
          user.reload
          expect(user.account_status).to eq('active')
        end

        # 5th failed attempt - should lock the account
        post '/api/v1/auth/login', params: { 
          auth: { mobile_number: user.mobile_number, password: 'WrongPassword' } 
        }
        expect(response).to have_http_status(:unauthorized)
        
        user.reload
        expect(user.account_status).to eq('locked')
        expect(user.failed_login_attempts).to eq(5)
        expect(user.locked_until).to be_present
        expect(user.locked_until).to be > Time.current
      end

      it 'prevents login while account is locked' do
        # Lock the account
        user.update(
          failed_login_attempts: 5,
          account_status: :locked,
          locked_until: Time.current + 15.minutes
        )

        # Try to login with correct password
        post '/api/v1/auth/login', params: { 
          auth: { mobile_number: user.mobile_number, password: password } 
        }
        
        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to match(/Account is locked/)
      end

      it 'automatically unlocks account after 15 minutes' do
        # Lock the account 16 minutes ago
        user.update(
          failed_login_attempts: 5,
          account_status: :locked,
          locked_until: Time.current - 1.minute
        )

        # Try to login with correct password
        post '/api/v1/auth/login', params: { 
          auth: { mobile_number: user.mobile_number, password: password } 
        }
        
        expect(response).to have_http_status(:success)
        
        user.reload
        expect(user.account_status).to eq('active')
        expect(user.failed_login_attempts).to eq(0)
        expect(user.locked_until).to be_nil
      end

      it 'resets failed attempts counter after successful login' do
        # Make 3 failed attempts
        3.times do
          post '/api/v1/auth/login', params: { 
            auth: { mobile_number: user.mobile_number, password: 'WrongPassword' } 
          }
        end
        
        user.reload
        expect(user.failed_login_attempts).to eq(3)

        # Successful login
        post '/api/v1/auth/login', params: { 
          auth: { mobile_number: user.mobile_number, password: password } 
        }
        
        expect(response).to have_http_status(:success)
        
        user.reload
        expect(user.failed_login_attempts).to eq(0)
        expect(user.account_status).to eq('active')
      end

      it 'increments failed attempts counter with each failed login' do
        3.times do |i|
          post '/api/v1/auth/login', params: { 
            auth: { mobile_number: user.mobile_number, password: 'WrongPassword' } 
          }
          
          user.reload
          expect(user.failed_login_attempts).to eq(i + 1)
        end
      end
    end
  end

  describe 'User#account_locked?' do
    it 'returns true when locked_until is in the future' do
      user.update(locked_until: Time.current + 10.minutes)
      expect(user.account_locked?).to be true
    end

    it 'returns false when locked_until is in the past' do
      user.update(locked_until: Time.current - 1.minute)
      expect(user.account_locked?).to be false
    end

    it 'returns false when locked_until is nil' do
      user.update(locked_until: nil)
      expect(user.account_locked?).to be false
    end
  end
end
