# frozen_string_literal: true

require 'rails_helper'
require 'benchmark'

RSpec.describe 'Dashboard Performance', type: :request do
  let!(:user) { 
    User.create!(
      mobile_number: '+989120000001',
      password: 'TestPassword123',
      password_confirmation: 'TestPassword123',
      account_status: 'active'
    )
  }
  
  before do
    # Seed market rates to avoid errors
    MarketRate.create!(rate_type: 'usd', value_in_toman: 42_500, timestamp: Time.current)
    MarketRate.create!(rate_type: 'gold_gram', value_in_toman: 2_150_000, timestamp: Time.current)
  end

  describe 'GET /api/v1/dashboard' do
    it 'returns within 2 seconds' do
      # Login to get valid token
      post '/api/v1/auth/login', params: {
        mobile_number: '+989120000001',
        password: 'TestPassword123'
      }
      
      response_body = JSON.parse(response.body)
      token = response_body.dig('data', 'token')
      
      expect(token).not_to be_nil, "Failed to get token from login response: #{response_body}"
      
      elapsed_time = Benchmark.realtime do
        get '/api/v1/dashboard', headers: { 'Authorization' => "Bearer #{token}" }
      end

      expect(response).to have_http_status(:ok)
      expect(elapsed_time).to be < 2.0
    end
  end
end
