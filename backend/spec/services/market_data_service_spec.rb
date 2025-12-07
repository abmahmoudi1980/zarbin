# frozen_string_literal: true

require "rails_helper"

RSpec.describe MarketDataService do
  describe ".fetch_and_store_rates" do
    let(:mock_response) do
      {
        "price_usd" => 42_000,
        "price_gold_grams" => 2_000_000,
        "price_bahar_azadi" => 19_000_000
      }
    end

    context "when TGJU API returns valid data" do
      before do
        allow(MarketDataService).to receive(:fetch_rates_from_tgju).and_return(mock_response)
      end

      it "returns true on success" do
        result = MarketDataService.fetch_and_store_rates
        expect(result).to be true
      end

      it "stores USD rate in database" do
        MarketDataService.fetch_and_store_rates
        
        usd_rate = MarketRate.find_by(rate_type: "usd")
        expect(usd_rate).to be_present
        expect(usd_rate.value_in_toman).to eq(42_000)
      end

      it "stores gold_gram rate in database" do
        MarketDataService.fetch_and_store_rates
        
        gold_rate = MarketRate.find_by(rate_type: "gold_gram")
        expect(gold_rate).to be_present
        expect(gold_rate.value_in_toman).to eq(2_000_000)
      end

      it "stores bahar_coin rate in database" do
        MarketDataService.fetch_and_store_rates
        
        coin_rate = MarketRate.find_by(rate_type: "bahar_coin")
        expect(coin_rate).to be_present
        expect(coin_rate.value_in_toman).to eq(19_000_000)
      end

      it "sets timestamp for each rate" do
        MarketDataService.fetch_and_store_rates
        
        MarketRate.all.each do |rate|
          expect(rate.timestamp).to be_present
          expect(rate.timestamp).to be_within(2.seconds).of(Time.current)
        end
      end

      it "creates new rates if they don't exist" do
        expect { MarketDataService.fetch_and_store_rates }.to change(MarketRate, :count).by(3)
      end

      it "updates existing rates on subsequent calls" do
        MarketDataService.fetch_and_store_rates
        initial_count = MarketRate.count
        
        # Update mock to return different values
        updated_response = {
          "price_usd" => 43_000,
          "price_gold_grams" => 2_050_000,
          "price_bahar_azadi" => 19_500_000
        }
        allow(MarketDataService).to receive(:fetch_rates_from_tgju).and_return(updated_response)
        
        MarketDataService.fetch_and_store_rates
        
        # Should not create new records, only update existing ones
        expect(MarketRate.count).to eq(initial_count)
        
        # Verify rates were updated
        expect(MarketRate.find_by(rate_type: "usd").value_in_toman).to eq(43_000)
      end
    end

    context "when TGJU API returns invalid data" do
      before do
        allow(MarketDataService).to receive(:fetch_rates_from_tgju).and_return(nil)
      end

      it "returns false" do
        result = MarketDataService.fetch_and_store_rates
        expect(result).to be false
      end

      it "does not create rates" do
        expect { MarketDataService.fetch_and_store_rates }.not_to change(MarketRate, :count)
      end
    end

    context "when TGJU API raises an error" do
      before do
        allow(MarketDataService).to receive(:fetch_rates_from_tgju).and_raise(StandardError, "API Error")
      end

      it "returns false" do
        result = MarketDataService.fetch_and_store_rates
        expect(result).to be false
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/Error fetching market rates/))
        MarketDataService.fetch_and_store_rates
      end

      it "does not create rates" do
        expect { MarketDataService.fetch_and_store_rates }.not_to change(MarketRate, :count)
      end
    end
  end

  describe ".get_current_rates" do
    context "when rates exist" do
      before do
        MarketRate.create!(rate_type: "usd", value_in_toman: 42_000, timestamp: Time.current)
        MarketRate.create!(rate_type: "gold_gram", value_in_toman: 2_000_000, timestamp: Time.current)
        MarketRate.create!(rate_type: "bahar_coin", value_in_toman: 19_000_000, timestamp: Time.current)
      end

      it "returns a hash with all three rates" do
        rates = MarketDataService.get_current_rates
        
        expect(rates).to be_a(Hash)
        expect(rates.keys).to match_array([:usd_rate, :gold_rate, :bahar_coin_rate, :timestamp])
      end

      it "returns correct USD rate" do
        rates = MarketDataService.get_current_rates
        expect(rates[:usd_rate]).to eq(42_000)
      end

      it "returns correct gold rate" do
        rates = MarketDataService.get_current_rates
        expect(rates[:gold_rate]).to eq(2_000_000)
      end

      it "returns correct bahar coin rate" do
        rates = MarketDataService.get_current_rates
        expect(rates[:bahar_coin_rate]).to eq(19_000_000)
      end

      it "returns timestamp" do
        rates = MarketDataService.get_current_rates
        expect(rates[:timestamp]).to be_present
      end
    end

    context "when no rates exist" do
      it "returns nil values for missing rates" do
        rates = MarketDataService.get_current_rates
        
        expect(rates[:usd_rate]).to be_nil
        expect(rates[:gold_rate]).to be_nil
        expect(rates[:bahar_coin_rate]).to be_nil
      end
    end
  end

  describe ".get_rate" do
    context "when rate exists" do
      before do
        MarketRate.create!(rate_type: "usd", value_in_toman: 42_000, timestamp: Time.current)
      end

      it "returns rate data for valid type" do
        rate = MarketDataService.get_rate("usd")
        
        expect(rate).to be_a(Hash)
        expect(rate[:rate_type]).to eq("usd")
        expect(rate[:value_in_toman]).to eq(42_000)
      end

      it "returns label for the rate" do
        rate = MarketDataService.get_rate("usd")
        expect(rate[:label]).to be_present
      end

      it "includes stale flag" do
        rate = MarketDataService.get_rate("usd")
        expect(rate).to have_key(:stale)
        expect(rate[:stale]).to be_in([true, false])
      end

      it "marks rate as not stale if recent" do
        rate = MarketDataService.get_rate("usd")
        expect(rate[:stale]).to be false
      end

      it "marks rate as stale if older than 5 minutes" do
        MarketRate.create!(
          rate_type: "gold_gram",
          value_in_toman: 2_000_000,
          timestamp: 6.minutes.ago
        )
        
        rate = MarketDataService.get_rate("gold_gram")
        expect(rate[:stale]).to be true
      end
    end

    context "when rate does not exist" do
      it "returns nil for unknown type" do
        rate = MarketDataService.get_rate("unknown_type")
        expect(rate).to be_nil
      end
    end
  end

  describe ".convert_to_currency" do
    before do
      MarketRate.create!(rate_type: "usd", value_in_toman: 42_000, timestamp: Time.current)
      MarketRate.create!(rate_type: "gold_gram", value_in_toman: 2_000_000, timestamp: Time.current)
    end

    context "when converting to USD" do
      it "converts toman to USD correctly" do
        result = MarketDataService.convert_to_currency(84_000, "usd")
        
        expect(result).to be_a(Hash)
        expect(result[:amount]).to eq(2)
        expect(result[:original_amount]).to eq(84_000)
        expect(result[:rate]).to eq(42_000)
      end

      it "handles decimal conversions" do
        result = MarketDataService.convert_to_currency(126_000, "usd")
        
        expect(result[:amount]).to eq(3)
      end

      it "handles partial conversions" do
        result = MarketDataService.convert_to_currency(63_000, "usd")
        
        expect(result[:amount]).to be_within(0.01).of(1.5)
      end
    end

    context "when converting to gold" do
      it "converts toman to grams of gold" do
        result = MarketDataService.convert_to_currency(4_000_000, "gold_gram")
        
        expect(result).to be_a(Hash)
        expect(result[:amount]).to eq(2)
      end
    end

    context "when target currency rate does not exist" do
      it "returns nil" do
        result = MarketDataService.convert_to_currency(100_000, "nonexistent")
        expect(result).to be_nil
      end
    end
  end
end
