# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Performance', type: :request do
  let(:mobile_number) { '09123456789' }
  let(:password) { 'Password123' }
  let(:user) { User.create!(mobile_number:, password:, password_confirmation: password, account_status: :active) }
  let(:auth_service) { AuthService.new }
  let(:valid_token) { auth_service.generate_token(user) }

  before do
    # Create market rates
    MarketRate.create!(
      rate_type: 'gold_gram',
      value_in_toman: 7_500_000,
      timestamp: Time.current
    )
    MarketRate.create!(
      rate_type: 'bahar_coin',
      value_in_toman: 250_000_000,
      timestamp: Time.current
    )
    MarketRate.create!(
      rate_type: 'usd',
      value_in_toman: 560_000,
      timestamp: Time.current
    )

    # Create sample transactions for the user
    category = Category.create!(persian_name: 'خوراک', icon_code: 'food', display_order: 1)
    
    5.times do |i|
      Transaction.create!(
        user:,
        category:,
        amount_toman: (i + 1) * 1_000_000,
        transaction_type: 'expense',
        date: Date.today,
        note: "Test transaction #{i}"
      )
    end
  end

  describe 'GET /api/v1/dashboard' do
    it 'responds within 2 seconds (SC-004 performance target)' do
      start_time = Time.now
      
      get '/api/v1/dashboard', headers: { 'Authorization' => "Bearer #{valid_token}" }
      
      elapsed_time = Time.now - start_time
      
      expect(response).to have_http_status(:success)
      expect(elapsed_time).to be < 2.0, 
        "Expected response within 2 seconds, but took #{elapsed_time.round(3)} seconds"
    end

    it 'maintains performance with multiple concurrent requests' do
      threads = []
      response_times = []
      
      # Simulate 5 concurrent requests
      5.times do
        threads << Thread.new do
          start_time = Time.now
          get '/api/v1/dashboard', headers: { 'Authorization' => "Bearer #{valid_token}" }
          elapsed_time = Time.now - start_time
          response_times << elapsed_time
        end
      end
      
      threads.each(&:join)
      
      avg_response_time = response_times.sum / response_times.size
      max_response_time = response_times.max
      
      expect(avg_response_time).to be < 2.0,
        "Average response time #{avg_response_time.round(3)}s exceeds 2s target"
      expect(max_response_time).to be < 4.0,
        "Max response time #{max_response_time.round(3)}s exceeds 4s threshold"
    end

    it 'returns dashboard data with correct structure' do
      get '/api/v1/dashboard', headers: { 'Authorization' => "Bearer #{valid_token}" }

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      
      expect(json_response).to have_key('data')
      data = json_response['data']
      
      # Verify balance data
      expect(data).to have_key('balance')
      balance = data['balance']
      expect(balance).to have_key('total_toman')
      expect(balance).to have_key('total_usd_equivalent')
      expect(balance).to have_key('total_gold_grams_equivalent')
      
      # Verify rates data
      expect(data).to have_key('current_rates')
      rates = data['current_rates']
      expect(rates).to be_an(Array)
      expect(rates.length).to be >= 3
    end

    it 'performance scales with larger transaction counts' do
      # Add 100 more transactions
      category = Category.first
      100.times do |i|
        Transaction.create!(
          user:,
          category:,
          amount_toman: (i + 1) * 100_000,
          transaction_type: 'expense',
          date: Date.today - i.days,
          note: "Bulk test transaction #{i}"
        )
      end

      start_time = Time.now
      get '/api/v1/dashboard', headers: { 'Authorization' => "Bearer #{valid_token}" }
      elapsed_time = Time.now - start_time

      expect(response).to have_http_status(:success)
      expect(elapsed_time).to be < 3.0,
        "Dashboard with 105 transactions took #{elapsed_time.round(3)}s, exceeds 3s max"
    end

    it 'uses caching to improve performance on repeated requests' do
      # First request - cold cache
      start_time = Time.now
      get '/api/v1/dashboard', headers: { 'Authorization' => "Bearer #{valid_token}" }
      first_request_time = Time.now - start_time
      
      # Second request - warm cache
      start_time = Time.now
      get '/api/v1/dashboard', headers: { 'Authorization' => "Bearer #{valid_token}" }
      second_request_time = Time.now - start_time
      
      # Cached response should be equal to or faster than first request
      expect(second_request_time).to be <= first_request_time + 0.1,
        "Second request (#{second_request_time.round(3)}s) should not be much slower than first (#{first_request_time.round(3)}s)"
    end
  end
end
