# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Market Rates Performance', type: :request do
  describe 'GET /api/v1/rates' do
    before do
      # Create sample market rates
      MarketRate.create!(
        rate_type: 'gold_gram',
        value_in_toman: 7_500_000,
        timestamp: Time.current
      )
      MarketRate.create!(
        rate_type: 'bahar_coin',
        value_in_toman: 150_000_000,
        timestamp: Time.current
      )
      MarketRate.create!(
        rate_type: 'usd',
        value_in_toman: 50_000,
        timestamp: Time.current
      )
    end

    it 'responds within 3 seconds (SC-002 performance target)' do
      start_time = Time.now
      
      get '/api/v1/rates'
      
      elapsed_time = Time.now - start_time
      
      expect(response).to have_http_status(:success)
      expect(elapsed_time).to be < 3.0, 
        "Expected response within 3 seconds, but took #{elapsed_time.round(3)} seconds"
    end

    it 'maintains performance with multiple concurrent requests' do
      threads = []
      response_times = []
      
      # Simulate 5 concurrent requests
      5.times do
        threads << Thread.new do
          start_time = Time.now
          get '/api/v1/rates'
          elapsed_time = Time.now - start_time
          response_times << elapsed_time
        end
      end
      
      threads.each(&:join)
      
      avg_response_time = response_times.sum / response_times.size
      max_response_time = response_times.max
      
      expect(avg_response_time).to be < 3.0,
        "Average response time #{avg_response_time.round(3)}s exceeds 3s target"
      expect(max_response_time).to be < 5.0,
        "Max response time #{max_response_time.round(3)}s exceeds 5s threshold"
    end

    it 'uses caching to improve performance on repeated requests' do
      # First request - cold cache
      start_time = Time.now
      get '/api/v1/rates'
      first_request_time = Time.now - start_time
      
      # Second request - warm cache
      start_time = Time.now
      get '/api/v1/rates'
      second_request_time = Time.now - start_time
      
      # Cached response should be significantly faster
      expect(second_request_time).to be < first_request_time,
        "Cached request (#{second_request_time.round(3)}s) should be faster than first (#{first_request_time.round(3)}s)"
    end
  end
end
