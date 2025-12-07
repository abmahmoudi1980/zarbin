# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Token Refresh Integration', type: :request do
  let(:mobile_number) { '09123456789' }
  let(:password) { 'Password123' }
  let(:user) { User.create!(mobile_number:, password:, password_confirmation: password, account_status: :active) }
  let(:auth_service) { AuthService.new }
  let(:valid_token) { auth_service.generate_token(user) }

  describe 'POST /api/v1/auth/refresh' do
    it 'refreshes a valid token successfully' do
      post '/api/v1/auth/refresh', headers: { 'Authorization' => "Bearer #{valid_token}" }

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      
      expect(json_response['success']).to be true
      expect(json_response['data']).to have_key('token')
      expect(json_response['data']).to have_key('expires_at')
      expect(json_response['data']).to have_key('expires_in')
      expect(json_response['data']['token_type']).to eq('Bearer')
      
      # New token should be different from old token
      new_token = json_response['data']['token']
      expect(new_token).not_to eq(valid_token)
    end

    it 'provides a token that expires in 7 days' do
      post '/api/v1/auth/refresh', headers: { 'Authorization' => "Bearer #{valid_token}" }

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      
      expires_in = json_response['data']['expires_in']
      seven_days_in_seconds = 7 * 24 * 60 * 60
      
      # Allow 1 minute tolerance for test execution time
      expect(expires_in).to be_within(60).of(seven_days_in_seconds)
    end

    it 'rejects refresh request with no token' do
      post '/api/v1/auth/refresh'

      expect(response).to have_http_status(:unauthorized)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('No token provided')
    end

    it 'rejects refresh request with invalid token' do
      post '/api/v1/auth/refresh', headers: { 'Authorization' => 'Bearer invalid_token' }

      expect(response).to have_http_status(:unauthorized)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Invalid token')
    end

    it 'allows user to maintain session for 7 days with token refresh' do
      # Day 1: Initial login
      post '/api/v1/auth/login', params: { 
        auth: { mobile_number: user.mobile_number, password: password } 
      }
      expect(response).to have_http_status(:success)
      token_day_1 = JSON.parse(response.body)['data']['token']

      # Simulate Day 6: Token still valid, refresh it
      # (In real scenario, this would be 6 days later)
      post '/api/v1/auth/refresh', headers: { 'Authorization' => "Bearer #{token_day_1}" }
      expect(response).to have_http_status(:success)
      token_day_6 = JSON.parse(response.body)['data']['token']

      # Verify new token works for authenticated requests
      get '/api/v1/transactions', headers: { 'Authorization' => "Bearer #{token_day_6}" }
      expect(response).to have_http_status(:success)
    end

    it 'new token can be used immediately for authenticated requests' do
      post '/api/v1/auth/refresh', headers: { 'Authorization' => "Bearer #{valid_token}" }
      expect(response).to have_http_status(:success)
      
      new_token = JSON.parse(response.body)['data']['token']

      # Use new token to access protected endpoint
      get '/api/v1/transactions', headers: { 'Authorization' => "Bearer #{new_token}" }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Token expiry behavior' do
    it 'expired token cannot access protected endpoints' do
      # Generate token that's already expired
      payload = {
        user_id: user.id,
        mobile_number: user.mobile_number,
        iat: (Time.now - 8.days).to_i,
        exp: (Time.now - 1.day).to_i
      }
      expired_token = JWT.encode(payload, Rails.application.key_generator.generate_key('jwt_secret', 32), 'HS256')

      get '/api/v1/transactions', headers: { 'Authorization' => "Bearer #{expired_token}" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
