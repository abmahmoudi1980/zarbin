require 'rails_helper'

RSpec.describe 'Api::V1::Auth', type: :request do
  describe 'POST /api/v1/auth/register' do
    let(:valid_params) do
      {
        mobile_number: '09123456789',
        password: 'Password123'
      }
    end

    context 'with valid parameters' do
      it 'creates a new user and returns success' do
        expect {
          post '/api/v1/auth/register', params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['mobile_number']).to eq('09123456789')
        expect(json['data']['account_status']).to eq('otp_pending')
      end

      it 'returns OTP sent confirmation' do
        post '/api/v1/auth/register', params: valid_params

        json = JSON.parse(response.body)
        expect(json['message']).to include('OTP')
      end
    end

    context 'with invalid mobile number' do
      it 'returns error for invalid Iranian number' do
        post '/api/v1/auth/register', params: {
          mobile_number: '1234567890',
          password: 'Password123'
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end

      it 'returns error for duplicate mobile number' do
        create(:user, mobile_number: '09123456789')

        post '/api/v1/auth/register', params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to include('already exists')
      end
    end

    context 'with invalid password' do
      it 'returns error for password too short' do
        post '/api/v1/auth/register', params: {
          mobile_number: '09123456789',
          password: 'Pass1'
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to include('password')
      end

      it 'returns error for password without number' do
        post '/api/v1/auth/register', params: {
          mobile_number: '09123456789',
          password: 'PasswordABC'
        }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /api/v1/auth/verify-otp' do
    let(:user) { create(:user, account_status: :otp_pending) }
    let(:otp_verification) { create(:otp_verification, mobile_number: user.mobile_number) }

    context 'with valid OTP' do
      it 'updates user status to active and returns token' do
        post '/api/v1/auth/verify-otp', params: {
          mobile_number: user.mobile_number,
          otp_code: otp_verification.otp_code
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['token']).to be_present
        expect(json['data']['account_status']).to eq('active')

        user.reload
        expect(user.account_status).to eq('active')
      end
    end

    context 'with invalid OTP' do
      it 'returns error for wrong code' do
        post '/api/v1/auth/verify-otp', params: {
          mobile_number: user.mobile_number,
          otp_code: '000000'
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end

      it 'returns error for expired OTP' do
        expired_otp = create(:otp_verification, 
          mobile_number: user.mobile_number,
          expires_at: 10.minutes.ago
        )

        post '/api/v1/auth/verify-otp', params: {
          mobile_number: user.mobile_number,
          otp_code: expired_otp.otp_code
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to include('expired')
      end
    end
  end

  describe 'POST /api/v1/auth/login' do
    let(:user) { create(:user, account_status: :active, password: 'Password123') }

    context 'with valid credentials' do
      it 'returns JWT token' do
        post '/api/v1/auth/login', params: {
          mobile_number: user.mobile_number,
          password: 'Password123'
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['token']).to be_present
        expect(json['data']['expires_in']).to be_present
      end

      it 'returns user info along with token' do
        post '/api/v1/auth/login', params: {
          mobile_number: user.mobile_number,
          password: 'Password123'
        }

        json = JSON.parse(response.body)
        expect(json['data']['mobile_number']).to eq(user.mobile_number)
        expect(json['data']['account_status']).to eq('active')
      end
    end

    context 'with invalid credentials' do
      it 'returns error for wrong password' do
        post '/api/v1/auth/login', params: {
          mobile_number: user.mobile_number,
          password: 'WrongPassword123'
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end

      it 'returns error for non-existent user' do
        post '/api/v1/auth/login', params: {
          mobile_number: '09999999999',
          password: 'Password123'
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'account lockout' do
      it 'locks account after 5 failed attempts' do
        5.times do
          post '/api/v1/auth/login', params: {
            mobile_number: user.mobile_number,
            password: 'WrongPassword'
          }
        end

        user.reload
        expect(user.failed_login_attempts).to eq(5)
        expect(user.account_locked?).to be true

        post '/api/v1/auth/login', params: {
          mobile_number: user.mobile_number,
          password: 'Password123'
        }

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to include('locked')
      end
    end
  end
end
