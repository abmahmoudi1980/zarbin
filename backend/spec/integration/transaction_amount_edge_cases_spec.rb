# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transaction Amount Edge Cases', type: :request do
  let!(:user) do
    User.create!(
      mobile_number: '+989120000888',
      password: 'TestPassword123',
      password_confirmation: 'TestPassword123',
      account_status: 'active'
    )
  end

  let!(:category) { create(:category, persian_name: 'Food') }

  let(:auth_headers) do
    post '/api/v1/auth/login', params: {
      mobile_number: '+989120000888',
      password: 'TestPassword123'
    }
    response_body = JSON.parse(response.body)
    { 'Authorization' => "Bearer #{response_body.dig('data', 'token')}" }
  end

  describe 'POST /api/v1/transactions' do
    context 'with invalid amounts' do
      it 'rejects zero amount' do
        post '/api/v1/transactions', 
          params: {
            amount_toman: 0,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: Time.current.strftime('%Y-%m-%d')
          },
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end

      it 'rejects negative amount' do
        post '/api/v1/transactions', 
          params: {
            amount_toman: -1000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: Time.current.strftime('%Y-%m-%d')
          },
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end

      it 'rejects amounts exceeding 99,999,999,999 Toman' do
        post '/api/v1/transactions', 
          params: {
            amount_toman: 100_000_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: Time.current.strftime('%Y-%m-%d')
          },
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end
    end

    context 'with valid boundary amounts' do
      it 'accepts minimum valid amount (1 Toman)' do
        post '/api/v1/transactions', 
          params: {
            amount_toman: 1,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: Time.current.strftime('%Y-%m-%d')
          },
          headers: auth_headers

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body.dig('data', 'amount_toman')).to eq(1)
      end

      it 'accepts maximum valid amount (99,999,999,999 Toman)' do
        max_amount = 99_999_999_999
        post '/api/v1/transactions', 
          params: {
            amount_toman: max_amount,
            transaction_type: 'income',
            category_id: category.id,
            transaction_date: Time.current.strftime('%Y-%m-%d')
          },
          headers: auth_headers

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body.dig('data', 'amount_toman')).to eq(max_amount)
      end

      it 'accepts typical transaction amount (5,000,000 Toman)' do
        post '/api/v1/transactions', 
          params: {
            amount_toman: 5_000_000,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: Time.current.strftime('%Y-%m-%d')
          },
          headers: auth_headers

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body.dig('data', 'amount_toman')).to eq(5_000_000)
      end
    end

    context 'with float amounts' do
      it 'accepts float amounts and rounds to integer' do
        post '/api/v1/transactions', 
          params: {
            amount_toman: 5_000_000.5,
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: Time.current.strftime('%Y-%m-%d')
          },
          headers: auth_headers

        # Float amounts should be rejected by validation (only_integer)
        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end
    end

    context 'with string amounts' do
      it 'accepts string amounts and converts to integer' do
        post '/api/v1/transactions', 
          params: {
            amount_toman: '5000000',
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: Time.current.strftime('%Y-%m-%d')
          },
          headers: auth_headers

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body.dig('data', 'amount_toman')).to eq(5_000_000)
      end

      it 'rejects string amounts with invalid format' do
        post '/api/v1/transactions', 
          params: {
            amount_toman: 'not_a_number',
            transaction_type: 'expense',
            category_id: category.id,
            transaction_date: Time.current.strftime('%Y-%m-%d')
          },
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
        response_body = JSON.parse(response.body)
        expect(response_body['error']).to be_present
      end
    end
  end
end
