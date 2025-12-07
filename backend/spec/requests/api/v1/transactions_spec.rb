require 'rails_helper'

RSpec.describe 'Api::V1::Transactions', type: :request do
  let(:user) { create(:user, account_status: :active) }
  let(:token) { AuthService.generate_token(user) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:category) { Category.find_by(persian_name: 'خوراک') || create(:category, persian_name: 'خوراک') }

  describe 'POST /api/v1/transactions' do
    let(:valid_params) do
      {
        amount_toman: 5_000_000,
        transaction_type: 'expense',
        category_id: category.id,
        transaction_date: '1403/01/15',
        notes: 'Grocery shopping'
      }
    end

    context 'with valid parameters' do
      it 'creates a new transaction and returns success' do
        expect {
          post '/api/v1/transactions', params: valid_params, headers: headers
        }.to change(Transaction, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['amount_toman']).to eq(5_000_000)
        expect(json['data']['transaction_type']).to eq('expense')
        expect(json['data']['user_id']).to eq(user.id)
      end

      it 'stores USD equivalent at creation time' do
        post '/api/v1/transactions', params: valid_params, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['usd_rate_at_creation']).to be_present
        expect(json['data']['amount_usd_equivalent']).to be_present
      end

      it 'returns transaction with Jalali date' do
        post '/api/v1/transactions', params: valid_params, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['transaction_date']).to eq('1403/01/15')
      end

      it 'includes category name in response' do
        post '/api/v1/transactions', params: valid_params, headers: headers

        json = JSON.parse(response.body)
        expect(json['data']['category_name']).to eq('خوراک')
      end
    end

    context 'with amount validation' do
      it 'rejects amount <= 0' do
        post '/api/v1/transactions', params: valid_params.merge(amount_toman: 0), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end

      it 'rejects amount > 99,999,999,999' do
        post '/api/v1/transactions', params: valid_params.merge(amount_toman: 100_000_000_000), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
      end

      it 'accepts valid amounts at boundaries' do
        post '/api/v1/transactions', params: valid_params.merge(amount_toman: 1), headers: headers
        expect(response).to have_http_status(:created)

        post '/api/v1/transactions', params: valid_params.merge(amount_toman: 99_999_999_999), headers: headers
        expect(response).to have_http_status(:created)
      end
    end

    context 'with missing required fields' do
      it 'returns error for missing amount_toman' do
        post '/api/v1/transactions', params: valid_params.except(:amount_toman), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to include('amount_toman')
      end

      it 'returns error for missing transaction_type' do
        post '/api/v1/transactions', params: valid_params.except(:transaction_type), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for missing transaction_date' do
        post '/api/v1/transactions', params: valid_params.except(:transaction_date), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid transaction_type' do
      it 'rejects invalid types' do
        post '/api/v1/transactions', params: valid_params.merge(transaction_type: 'invalid'), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'accepts income and expense' do
        post '/api/v1/transactions', params: valid_params.merge(transaction_type: 'income'), headers: headers
        expect(response).to have_http_status(:created)

        post '/api/v1/transactions', params: valid_params.merge(transaction_type: 'expense'), headers: headers
        expect(response).to have_http_status(:created)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        post '/api/v1/transactions', params: valid_params

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with optional category_id' do
      it 'creates transaction without category (defaults to Other)' do
        post '/api/v1/transactions', params: valid_params.except(:category_id), headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['data']['category_id']).to be_present
      end
    end
  end

  describe 'GET /api/v1/transactions' do
    let!(:transaction1) { create(:transaction, user: user, amount_toman: 5_000_000, transaction_date: '1403/01/15') }
    let!(:transaction2) { create(:transaction, user: user, amount_toman: 3_000_000, transaction_date: '1403/01/20') }
    let!(:other_user_transaction) { create(:transaction, amount_toman: 1_000_000) }

    context 'with valid authentication' do
      it 'returns all user transactions' do
        get '/api/v1/transactions', headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']).to be_an(Array)
        expect(json['data'].length).to eq(2)
      end

      it 'returns transactions sorted by date (newest first)' do
        get '/api/v1/transactions', headers: headers

        json = JSON.parse(response.body)
        dates = json['data'].map { |t| t['transaction_date'] }
        expect(dates).to eq(['1403/01/20', '1403/01/15'])
      end

      it 'includes all transaction details' do
        get '/api/v1/transactions', headers: headers

        json = JSON.parse(response.body)
        transaction_data = json['data'].first
        expect(transaction_data).to include(
          'id',
          'amount_toman',
          'transaction_type',
          'transaction_date',
          'category_name',
          'notes',
          'usd_rate_at_creation',
          'amount_usd_equivalent'
        )
      end

      it 'excludes other users transactions' do
        get '/api/v1/transactions', headers: headers

        json = JSON.parse(response.body)
        user_ids = json['data'].map { |t| t['user_id'] }
        expect(user_ids).to all(eq(user.id))
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        get '/api/v1/transactions'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with pagination' do
      before do
        create_list(:transaction, 15, user: user)
      end

      it 'returns paginated results' do
        get '/api/v1/transactions', params: { page: 1, per_page: 10 }, headers: headers

        json = JSON.parse(response.body)
        expect(json['data'].length).to be <= 10
        expect(json['pagination']).to include('current_page', 'total_pages', 'total_count')
      end
    end
  end

  describe 'GET /api/v1/transactions/:id' do
    let(:transaction) { create(:transaction, user: user) }

    context 'with valid transaction id' do
      it 'returns the transaction details' do
        get "/api/v1/transactions/#{transaction.id}", headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['id']).to eq(transaction.id)
      end
    end

    context 'with other user transaction' do
      let(:other_transaction) { create(:transaction) }

      it 'returns forbidden error' do
        get "/api/v1/transactions/#{other_transaction.id}", headers: headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid transaction id' do
      it 'returns not found error' do
        get '/api/v1/transactions/99999', headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        get "/api/v1/transactions/#{transaction.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/transactions/:id' do
    let(:transaction) { create(:transaction, user: user) }
    let(:update_params) do
      {
        amount_toman: 10_000_000,
        notes: 'Updated note'
      }
    end

    context 'with valid parameters' do
      it 'updates the transaction' do
        patch "/api/v1/transactions/#{transaction.id}", params: update_params, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['amount_toman']).to eq(10_000_000)
        expect(json['data']['notes']).to eq('Updated note')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        patch "/api/v1/transactions/#{transaction.id}", params: update_params

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/transactions/:id' do
    let(:transaction) { create(:transaction, user: user) }

    context 'with valid transaction id' do
      it 'deletes the transaction' do
        expect {
          delete "/api/v1/transactions/#{transaction.id}", headers: headers
        }.to change(Transaction, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        delete "/api/v1/transactions/#{transaction.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
