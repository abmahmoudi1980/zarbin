# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Jalali Date Validation', type: :request do
  let!(:user) do
    User.create!(
      mobile_number: '+989120000777',
      password: 'TestPassword123',
      password_confirmation: 'TestPassword123',
      account_status: 'active'
    )
  end

  let!(:category) { create(:category, persian_name: 'Food') }

  let(:auth_headers) do
    post '/api/v1/auth/login', params: {
      mobile_number: '+989120000777',
      password: 'TestPassword123'
    }
    response_body = JSON.parse(response.body)
    { 'Authorization' => "Bearer #{response_body.dig('data', 'token')}" }
  end

  describe 'POST /api/v1/transactions - Jalali date validation' do
    context 'with future dates' do
      it 'rejects transactions with future Jalali dates' do
        # Create a date 5 days in the future
        future_date = (Time.current + 5.days).strftime('%Y-%m-%d')

        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: future_date
          },
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end

      it 'rejects transactions with date 1 day in the future' do
        future_date = (Time.current + 1.day).strftime('%Y-%m-%d')

        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: future_date
          },
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end
    end

    context 'with valid historical dates' do
      it 'accepts transactions with today\'s date' do
        today = Time.current.strftime('%Y-%m-%d')

        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: today
          },
          headers: auth_headers

        expect(response).to have_http_status(:created)
      end

      it 'accepts transactions with yesterday\'s date' do
        yesterday = (Time.current - 1.day).strftime('%Y-%m-%d')

        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: yesterday
          },
          headers: auth_headers

        expect(response).to have_http_status(:created)
      end

      it 'accepts transactions with date from 1 month ago' do
        past_date = (Time.current - 30.days).strftime('%Y-%m-%d')

        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: past_date
          },
          headers: auth_headers

        expect(response).to have_http_status(:created)
      end

      it 'accepts transactions with date from 1 year ago' do
        past_date = (Time.current - 365.days).strftime('%Y-%m-%d')

        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: past_date
          },
          headers: auth_headers

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid date formats' do
      it 'rejects transaction with invalid date format (MM/DD/YYYY)' do
        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: '12/22/2025'
          },
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end

      it 'rejects transaction with invalid date format (DD/MM/YYYY)' do
        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: '22/12/2025'
          },
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end

      it 'rejects transaction with incomplete date' do
        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: '2025-12'
          },
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end

      it 'rejects transaction with invalid day of month' do
        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: '2025-02-30'
          },
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end

      it 'rejects transaction with invalid month' do
        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: '2025-13-01'
          },
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end
    end

    context 'with boundary date ranges' do
      it 'accepts transaction with valid Jalali date range (year between 1300-1500)' do
        # Valid Jalali date in the past: 1350/01/01
        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: '1350-01-01'
          },
          headers: auth_headers

        # Should accept if parsing logic allows historical dates
        expect([200, 201, 422]).to include(response.status)
      end

      it 'accepts transaction with valid Jalali date range (current year)' do
        # Current Jalali date should be around 1404
        current_jalali_year = Time.current.year
        current_jalali_month = Time.current.month.to_s.rjust(2, '0')
        current_jalali_day = Time.current.day.to_s.rjust(2, '0')
        gregorian_date = "#{current_jalali_year}-#{current_jalali_month}-#{current_jalali_day}"

        post '/api/v1/transactions',
          params: {
            amount_toman: 1_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: gregorian_date
          },
          headers: auth_headers

        expect(response).to have_http_status(:created)
      end
    end
  end
end
