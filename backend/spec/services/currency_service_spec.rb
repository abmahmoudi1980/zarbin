require 'rails_helper'

RSpec.describe CurrencyService, type: :service do
  before do
    MarketRate.delete_all
  end

  describe '.toman_to_usd' do
    context 'with valid exchange rate' do
      it 'converts Toman to USD using current rate' do
        rate = MarketRate.create!(rate_type: 'usd', value_in_toman: 42500, timestamp: Time.current)

        result = CurrencyService.toman_to_usd(42_500_000)

        expect(result).to eq(1000.0)
      end

      it 'handles fractional conversions' do
        MarketRate.create!(rate_type: 'usd', value_in_toman: 42500, timestamp: Time.current)

        result = CurrencyService.toman_to_usd(42_500)

        expect(result).to be_within(0.01).of(1.0)
      end

      it 'returns 0 for 0 Toman' do
        MarketRate.create!(rate_type: 'usd', value_in_toman: 42500, timestamp: Time.current)

        result = CurrencyService.toman_to_usd(0)

        expect(result).to eq(0.0)
      end
    end

    context 'without valid exchange rate' do
      it 'raises error when USD rate not available' do
        expect {
          CurrencyService.toman_to_usd(1_000_000)
        }.to raise_error(CurrencyService::ExchangeRateNotAvailable)
      end
    end

    context 'with very large amounts' do
      it 'handles amounts up to 99,999,999,999 Toman' do
        MarketRate.create!(rate_type: 'usd', value_in_toman: 42500, timestamp: Time.current)

        result = CurrencyService.toman_to_usd(99_999_999_999)

        expect(result).to be_a(Float)
        expect(result).to be > 0
      end
    end
  end

  describe '.toman_to_gold_grams' do
    context 'with valid gold rate' do
      it 'converts Toman to gold grams using current rate' do
        MarketRate.create!(rate_type: 'gold_gram', value_in_toman: 2_000_000, timestamp: Time.current)

        result = CurrencyService.toman_to_gold_grams(2_000_000)

        expect(result).to eq(1.0)
      end

      it 'handles fractional grams' do
        MarketRate.create!(rate_type: 'gold_gram', value_in_toman: 2_000_000, timestamp: Time.current)

        result = CurrencyService.toman_to_gold_grams(1_000_000)

        expect(result).to be_within(0.001).of(0.5)
      end
    end

    context 'without valid gold rate' do
      it 'raises error when gold rate not available' do
        expect {
          CurrencyService.toman_to_gold_grams(1_000_000)
        }.to raise_error(CurrencyService::ExchangeRateNotAvailable)
      end
    end
  end

  describe '.get_current_rate' do
    context 'with existing rate' do
      it 'returns the most recent rate for rate_type' do
        old_rate = MarketRate.create!(rate_type: 'usd', value_in_toman: 42000, timestamp: 1.day.ago)
        current_rate = MarketRate.create!(rate_type: 'usd', value_in_toman: 42500, timestamp: Time.current)

        result = CurrencyService.get_current_rate('USD')

        expect(result).to eq(42500)
      end
    end

    context 'without existing rate' do
      it 'returns nil when no rate available' do
        result = CurrencyService.get_current_rate('BTC')

        expect(result).to be_nil
      end
    end
  end

  describe '.record_transaction_rate' do
    context 'when creating a transaction' do
      it 'records the exchange rate at transaction creation time' do
        MarketRate.create!(rate_type: 'usd', value_in_toman: 42500, timestamp: Time.current)

        rate = CurrencyService.record_transaction_rate('usd')

        expect(rate).to eq(42500.0)
      end

      it 'handles multiple rate types' do
        MarketRate.create!(rate_type: 'usd', value_in_toman: 42500, timestamp: Time.current)
        MarketRate.create!(rate_type: 'gold_gram', value_in_toman: 2_000_000, timestamp: Time.current)

        usd_rate = CurrencyService.record_transaction_rate('usd')
        gold_rate = CurrencyService.record_transaction_rate('gold_gram')

        expect(usd_rate).to eq(42500.0)
        expect(gold_rate).to eq(2_000_000.0)
      end
    end
  end

  describe '.equivalent_at_rate' do
    it 'calculates equivalent amount at a historical rate' do
      result = CurrencyService.equivalent_at_rate(5_000_000, 42500.0)

      expect(result).to be_within(0.01).of(117.65)
    end

    it 'handles rate changes' do
      old_rate = 40000.0
      new_rate = 45000.0

      old_equivalent = CurrencyService.equivalent_at_rate(5_000_000, old_rate)
      new_equivalent = CurrencyService.equivalent_at_rate(5_000_000, new_rate)

      expect(new_equivalent).to be < old_equivalent
    end
  end

  describe '.bulk_convert' do
    before do
      MarketRate.create!(rate_type: 'usd', value_in_toman: 42500, timestamp: Time.current)
    end

    it 'converts multiple amounts at once' do
      amounts = [1_000_000, 2_000_000, 5_000_000]

      results = CurrencyService.bulk_convert(amounts)

      expect(results).to be_an(Array)
      expect(results.length).to eq(3)
      expect(results.all? { |r| r.is_a?(Float) }).to be true
    end

    it 'preserves order in bulk conversion' do
      amounts = [1_000_000, 2_000_000, 5_000_000]

      results = CurrencyService.bulk_convert(amounts)

      expect(results[0]).to be < results[1]
      expect(results[1]).to be < results[2]
    end
  end

  describe 'error handling' do
    describe 'ExchangeRateNotAvailable' do
      it 'is raised when rate type is not found' do
        expect {
          CurrencyService.toman_to_usd(1_000_000)
        }.to raise_error(CurrencyService::ExchangeRateNotAvailable)
      end

      it 'includes helpful error message' do
        begin
          CurrencyService.toman_to_usd(1_000_000)
        rescue CurrencyService::ExchangeRateNotAvailable => e
          expect(e.message).to include('USD')
        end
      end
    end
  end

  describe 'precision' do
    before do
      MarketRate.create!(rate_type: 'usd', value_in_toman: 42500, timestamp: Time.current)
    end

    it 'maintains precision for currency conversions' do
      # 1,000,000 Toman ÷ 42,500 = 23.529... USD
      result = CurrencyService.toman_to_usd(1_000_000)

      expect(result.round(2)).to eq(23.53)
    end

    it 'does not introduce floating point errors' do
      amount1 = 1_000_000
      amount2 = 2_000_000

      result1 = CurrencyService.toman_to_usd(amount1)
      result2 = CurrencyService.toman_to_usd(amount2)

      # 2 × amount1 should equal amount2 (within floating point tolerance)
      expect((result2 - (result1 * 2)).abs).to be < 0.01
    end
  end
end
