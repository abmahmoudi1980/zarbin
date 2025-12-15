# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Dashboard", type: :request do
  let(:user) { create(:user, mobile_number: "09120000001") }
  let(:auth_headers) do
    post "/api/v1/auth/login", params: {
      mobile_number: "+989120000001",
      password: "TestPassword123"
    }
    { "Authorization" => "Bearer #{JSON.parse(response.body)['token']}" }
  end

  before do
    # Create market rates for conversions
    MarketRate.create!(
      rate_type: "usd",
      value_in_toman: 42_500,
      timestamp: Time.current
    )
    MarketRate.create!(
      rate_type: "gold_gram",
      value_in_toman: 2_150_000,
      timestamp: Time.current
    )
  end

  describe "GET /api/v1/dashboard" do
    context "when user is authenticated and has no transactions" do
      it "returns 200 OK" do
        get "/api/v1/dashboard", headers: auth_headers
        expect(response).to have_http_status(:ok)
      end

      it "returns zero balance for new user" do
        get "/api/v1/dashboard", headers: auth_headers
        json = JSON.parse(response.body)

        expect(json["total_toman"]).to eq(0)
        expect(json["total_usd_equivalent"]).to eq(0.0)
        expect(json["total_gold_grams_equivalent"]).to eq(0.0)
      end

      it "includes last_updated timestamp in Jalali format" do
        get "/api/v1/dashboard", headers: auth_headers
        json = JSON.parse(response.body)

        expect(json).to have_key("last_updated")
        # Jalali format: YYYY/MM/DD HH:MM:SS
        expect(json["last_updated"]).to match(/\d{4}\/\d{2}\/\d{2}\s\d{2}:\d{2}:\d{2}/)
      end
    end

    context "when user is authenticated and has transactions" do
      before do
        # Create income and expense transactions
        Transaction.create!(
          user_id: user.id,
          amount_toman: 100_000_000,
          type: "income",
          date: Date.current,
          category_id: Category.find_by(persian_name: "سایر").id,
          note: "Test income"
        )
        Transaction.create!(
          user_id: user.id,
          amount_toman: 30_000_000,
          type: "expense",
          date: Date.current,
          category_id: Category.find_by(persian_name: "خوراک").id,
          note: "Test expense"
        )
        # Balance should be 70,000,000 Toman
      end

      it "returns calculated balance with all transactions" do
        get "/api/v1/dashboard", headers: auth_headers
        json = JSON.parse(response.body)

        # 100M (income) - 30M (expense) = 70M
        expect(json["total_toman"]).to eq(70_000_000)
      end

      it "calculates USD equivalent correctly" do
        get "/api/v1/dashboard", headers: auth_headers
        json = JSON.parse(response.body)

        # 70M / 42500 = 1647.06 USD
        expected_usd = (70_000_000.to_f / 42_500).round(2)
        expect(json["total_usd_equivalent"]).to eq(expected_usd)
      end

      it "calculates gold gram equivalent correctly" do
        get "/api/v1/dashboard", headers: auth_headers
        json = JSON.parse(response.body)

        # 70M / 2150000 = 32.558 grams
        expected_gold = (70_000_000.to_f / 2_150_000).round(3)
        expect(json["total_gold_grams_equivalent"]).to eq(expected_gold)
      end

      it "includes correct response structure" do
        get "/api/v1/dashboard", headers: auth_headers
        json = JSON.parse(response.body)

        expect(json).to include(
          "total_toman",
          "total_usd_equivalent",
          "total_gold_grams_equivalent",
          "last_updated"
        )
      end

      it "updates equivalents when market rates change" do
        get "/api/v1/dashboard", headers: auth_headers
        initial_response = JSON.parse(response.body)

        # Update market rate
        MarketRate.find_by(rate_type: "usd").update!(
          value_in_toman: 50_000,
          timestamp: Time.current
        )

        get "/api/v1/dashboard", headers: auth_headers
        updated_response = JSON.parse(response.body)

        # Toman amount should remain the same
        expect(updated_response["total_toman"]).to eq(initial_response["total_toman"])
        # USD equivalent should change
        expect(updated_response["total_usd_equivalent"]).not_to eq(initial_response["total_usd_equivalent"])
      end
    end

    context "when user is not authenticated" do
      it "returns 401 Unauthorized" do
        get "/api/v1/dashboard"
        expect(response).to have_http_status(:unauthorized)
      end

      it 'includes error message' do
        expect(json).to include("error" => "Token missing")
      end
    end

    context "when user has large transactions" do
      before do
        # Create large transactions near max value
        Transaction.create!(
          user_id: user.id,
          amount_toman: 50_000_000_000,
          type: "income",
          date: Date.current,
          category_id: Category.find_by(persian_name: "سایر").id
        )
      end

      it "handles large amounts without overflow" do
        get "/api/v1/dashboard", headers: auth_headers
        json = JSON.parse(response.body)

        expect(json["total_toman"]).to eq(50_000_000_000)
        expect(json["total_usd_equivalent"]).to be_positive
      end
    end

    context "when market rates are missing" do
      before do
        MarketRate.destroy_all
      end

      it "returns 200 with zero equivalents" do
        get "/api/v1/dashboard", headers: auth_headers
        expect(response).to have_http_status(:ok)
        
        json = JSON.parse(response.body)
        expect(json["total_usd_equivalent"]).to eq(0.0)
        expect(json["total_gold_grams_equivalent"]).to eq(0.0)
      end
    end
  end

  describe "GET /api/v1/dashboard/spending-breakdown" do
    context "when user is authenticated and has no transactions" do
      it "returns 200 OK with empty categories" do
        get "/api/v1/dashboard/spending-breakdown", headers: auth_headers
        expect(response).to have_http_status(:ok)
        
        json = JSON.parse(response.body)
        expect(json["breakdown"]).to be_an(Array)
        expect(json["breakdown"]).to be_empty
      end

      it "returns current Jalali month" do
        get "/api/v1/dashboard/spending-breakdown", headers: auth_headers
        json = JSON.parse(response.body)
        
        expect(json).to have_key("current_month")
        # Jalali format: YYYY/MM
        expect(json["current_month"]).to match(/\d{4}\/\d{2}/)
      end
    end

    context "when user has transactions in current Jalali month" do
      before do
        # Create transactions in different categories for current month
        food_category = Category.find_by(persian_name: "خوراک")
        transport_category = Category.find_by(persian_name: "حمل‌ونقل")
        
        Transaction.create!(
          user_id: user.id,
          amount_toman: 5_000_000,
          type: "expense",
          date: Date.current,
          category_id: food_category.id
        )
        
        Transaction.create!(
          user_id: user.id,
          amount_toman: 2_000_000,
          type: "expense",
          date: Date.current,
          category_id: transport_category.id
        )
      end

      it "returns spending breakdown by category" do
        get "/api/v1/dashboard/spending-breakdown", headers: auth_headers
        json = JSON.parse(response.body)

        expect(json["breakdown"]).to be_an(Array)
        expect(json["breakdown"].length).to eq(2)
      end

      it "includes required fields for each category breakdown" do
        get "/api/v1/dashboard/spending-breakdown", headers: auth_headers
        json = JSON.parse(response.body)

        category_data = json["breakdown"].first
        expect(category_data).to have_keys(
          "category_id",
          "category_persian_name",
          "category_icon",
          "total_amount",
          "percentage"
        )
      end

      it "calculates correct percentages" do
        get "/api/v1/dashboard/spending-breakdown", headers: auth_headers
        json = JSON.parse(response.body)

        total = json["breakdown"].sum { |c| c["total_amount"] }
        json["breakdown"].each do |category|
          expected_percentage = (category["total_amount"].to_f / total * 100).round(2)
          expect(category["percentage"]).to eq(expected_percentage)
        end
      end

      it "returns breakdown sorted by amount (descending)" do
        get "/api/v1/dashboard/spending-breakdown", headers: auth_headers
        json = JSON.parse(response.body)

        amounts = json["breakdown"].map { |c| c["total_amount"] }
        expect(amounts).to eq(amounts.sort.reverse)
      end

      it "includes total spending amount" do
        get "/api/v1/dashboard/spending-breakdown", headers: auth_headers
        json = JSON.parse(response.body)

        expect(json).to have_key("total_spending")
        expect(json["total_spending"]).to eq(7_000_000)
      end
    end

    context "when user has transactions in different months" do
      before do
        food_category = Category.find_by(persian_name: "خوراک")
        
        # Current month transaction
        Transaction.create!(
          user_id: user.id,
          amount_toman: 5_000_000,
          type: "expense",
          date: Date.current,
          category_id: food_category.id
        )
        
        # Previous month transaction (should be excluded)
        Transaction.create!(
          user_id: user.id,
          amount_toman: 10_000_000,
          type: "expense",
          date: 40.days.ago,
          category_id: food_category.id
        )
      end

      it "only includes transactions from current Jalali month" do
        get "/api/v1/dashboard/spending-breakdown", headers: auth_headers
        json = JSON.parse(response.body)

        # Only the current month transaction (5M) should be included
        expect(json["total_spending"]).to eq(5_000_000)
      end
    end

    context "when user has income and expense transactions" do
      before do
        category = Category.find_by(persian_name: "سایر")
        
        # Income transaction
        Transaction.create!(
          user_id: user.id,
          amount_toman: 20_000_000,
          type: "income",
          date: Date.current,
          category_id: category.id
        )
        
        # Expense transaction
        Transaction.create!(
          user_id: user.id,
          amount_toman: 5_000_000,
          type: "expense",
          date: Date.current,
          category_id: category.id
        )
      end

      it "only includes expense transactions in breakdown" do
        get "/api/v1/dashboard/spending-breakdown", headers: auth_headers
        json = JSON.parse(response.body)

        expect(json["total_spending"]).to eq(5_000_000)
      end
    end

    context "when user is not authenticated" do
      it "returns 401 Unauthorized" do
        get "/api/v1/dashboard/spending-breakdown"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
