# frozen_string_literal: true

require 'rails_helper'
require 'benchmark'

RSpec.describe 'Market Rates Performance', type: :request do
  describe 'GET /api/v1/rates' do
    it 'returns within 3 seconds' do
      elapsed_time = Benchmark.realtime do
        get '/api/v1/rates'
      end

      expect(response).to have_http_status(:ok)
      expect(elapsed_time).to be < 3.0
    end
  end
end
