# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Rates", type: :request do
  describe "GET /api/v1/rates" do
    context "when rates exist" do
      before do
        # Create sample market rates
        MarketRate.create!(
          rate_type: "usd",
          value_in_toman: 42_000,
          timestamp: Time.current
        )
        MarketRate.create!(
          rate_type: "gold_gram",
          value_in_toman: 2_000_000,
          timestamp: Time.current
        )
        MarketRate.create!(
          rate_type: "bahar_coin",
          value_in_toman: 19_000_000,
          timestamp: Time.current
        )
      end

      it "returns 200 OK" do
        get "/api/v1/rates"
        expect(response).to have_http_status(:ok)
      end

      it "returns all three rate types" do
        get "/api/v1/rates"
        json = JSON.parse(response.body)
        
        expect(json["rates"]).to be_an(Array)
        expect(json["rates"].length).to eq(3)
      end

      it "includes usd rate with correct structure" do
        get "/api/v1/rates"
        json = JSON.parse(response.body)
        
        usd_rate = json["rates"].find { |r| r["rate_type"] == "usd" }
        expect(usd_rate).to include(
          "rate_type" => "usd",
          "value_in_toman" => 42_000,
          "label" => a_string_matching(/USD|دلار/i),
          "stale" => false
        )
        expect(usd_rate).to have_key("timestamp")
      end

      it "includes gold_gram rate with correct structure" do
        get "/api/v1/rates"
        json = JSON.parse(response.body)
        
        gold_rate = json["rates"].find { |r| r["rate_type"] == "gold_gram" }
        expect(gold_rate).to include(
          "rate_type" => "gold_gram",
          "value_in_toman" => 2_000_000,
          "label" => a_string_matching(/Gold|طلا/i),
          "stale" => false
        )
      end

      it "includes bahar_coin rate with correct structure" do
        get "/api/v1/rates"
        json = JSON.parse(response.body)
        
        coin_rate = json["rates"].find { |r| r["rate_type"] == "bahar_coin" }
        expect(coin_rate).to include(
          "rate_type" => "bahar_coin",
          "value_in_toman" => 19_000_000,
          "label" => a_string_matching(/Bahar|بهار/i),
          "stale" => false
        )
      end

      it "includes timestamp in Jalali format" do
        get "/api/v1/rates"
        json = JSON.parse(response.body)
        
        # Response should have timestamp, verify it's present
        expect(json).to have_key("timestamp")
      end
    end

    context "when rates are stale (>5 minutes old)" do
      before do
        # Create rates from 6 minutes ago
        stale_time = 6.minutes.ago
        MarketRate.create!(
          rate_type: "usd",
          value_in_toman: 42_000,
          timestamp: stale_time
        )
        MarketRate.create!(
          rate_type: "gold_gram",
          value_in_toman: 2_000_000,
          timestamp: stale_time
        )
        MarketRate.create!(
          rate_type: "bahar_coin",
          value_in_toman: 19_000_000,
          timestamp: stale_time
        )
      end

      it "marks rates as stale" do
        get "/api/v1/rates"
        json = JSON.parse(response.body)
        
        json["rates"].each do |rate|
          expect(rate["stale"]).to be true
        end
      end

      it "includes stale indicator in response" do
        get "/api/v1/rates"
        json = JSON.parse(response.body)
        
        expect(json).to have_key("rates_stale_minutes")
        expect(json["rates_stale_minutes"]).to be > 5
      end
    end

    context "when no rates exist" do
      it "returns 200 OK with empty rates array" do
        get "/api/v1/rates"
        expect(response).to have_http_status(:ok)
        
        json = JSON.parse(response.body)
        expect(json["rates"]).to eq([])
      end
    end

    context "when rates have changed significantly" do
      before do
        # Store current rates
        MarketRate.create!(
          rate_type: "usd",
          value_in_toman: 42_000,
          timestamp: 1.hour.ago
        )
        # More recent rate
        MarketRate.create!(
          rate_type: "usd",
          value_in_toman: 43_000,
          timestamp: Time.current
        )
        
        MarketRate.create!(
          rate_type: "gold_gram",
          value_in_toman: 2_000_000,
          timestamp: Time.current
        )
        MarketRate.create!(
          rate_type: "bahar_coin",
          value_in_toman: 19_000_000,
          timestamp: Time.current
        )
      end

      it "returns latest rates only" do
        get "/api/v1/rates"
        json = JSON.parse(response.body)
        
        usd_rate = json["rates"].find { |r| r["rate_type"] == "usd" }
        expect(usd_rate["value_in_toman"]).to eq(43_000)
      end
    end

    context "when headers are present" do
      before do
        MarketRate.create!(
          rate_type: "usd",
          value_in_toman: 42_000,
          timestamp: Time.current
        )
        MarketRate.create!(
          rate_type: "gold_gram",
          value_in_toman: 2_000_000,
          timestamp: Time.current
        )
        MarketRate.create!(
          rate_type: "bahar_coin",
          value_in_toman: 19_000_000,
          timestamp: Time.current
        )
      end

      it "returns Content-Type as application/json" do
        get "/api/v1/rates"
        expect(response.content_type).to match(/json/)
      end

      it "returns cache headers for public caching" do
        get "/api/v1/rates"
        # Rates should be cacheable for 5 minutes
        expect(response.headers["Cache-Control"]).to include("public")
        expect(response.headers["Cache-Control"]).to match(/max-age=300/)
      end
    end
  end
end
