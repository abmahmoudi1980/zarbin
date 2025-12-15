require 'rails_helper'

RSpec.describe 'API::V1::Categories', type: :request do
  let(:user) { create(:user, account_status: 'active') }
  let(:auth_header) { { 'Authorization' => "Bearer #{user.tokens.create.token}" } }

  describe 'GET /api/v1/categories' do
    context 'when user is authenticated' do
      it 'returns all categories with correct structure' do
        get '/api/v1/categories', headers: auth_header

        expect(response).to have_http_status(:ok)
        expect(response_body).to have_key('categories')
        expect(response_body['categories']).to be_an(Array)
      end

      it 'returns all 7 predefined categories' do
        get '/api/v1/categories', headers: auth_header

        expect(response_body['categories'].count).to eq(7)
      end

      it 'includes required fields for each category' do
        get '/api/v1/categories', headers: auth_header

        category = response_body['categories'].first
        expect(category).to have_keys('id', 'name_fa', 'name_en', 'icon', 'display_order')
      end

      it 'returns categories in correct display order' do
        get '/api/v1/categories', headers: auth_header

        categories = response_body['categories']
        display_orders = categories.map { |c| c['display_order'] }
        expect(display_orders).to eq(display_orders.sort)
      end

      it 'includes Food, Transport, Bills, Shopping, Health, Entertainment, Other' do
        get '/api/v1/categories', headers: auth_header

        category_names = response_body['categories'].map { |c| c['persian_name'] }
        expect(category_names).to include('خوراک', 'حمل‌ونقل', 'قبوض', 'خرید', 'سلامت', 'تفریح', 'سایر')
      end

      it 'includes valid icon codes for each category' do
        get '/api/v1/categories', headers: auth_header

        response_body['categories'].each do |category|
          expect(category['icon']).to match(/^[a-z0-9_]+$/i)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        get '/api/v1/categories'

        expect(response).to have_http_status(:unauthorized)
        expect(response_body).to have_key('error')
      end
    end

    context 'when user account is locked' do
      before { user.update(status: 'locked') }

      it 'returns forbidden status' do
        get '/api/v1/categories', headers: auth_header

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  private

  def response_body
    JSON.parse(response.body)
  end
end
