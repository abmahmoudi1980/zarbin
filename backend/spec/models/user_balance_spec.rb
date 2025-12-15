# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserBalance, type: :model do
  let(:user) { create(:user, :with_balance) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build(:user_balance, user: create(:user, :skip_balance)) }

    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_uniqueness_of(:user_id) }
    it { is_expected.to validate_numericality_of(:total_toman).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:total_usd_equivalent).is_greater_than_or_equal_to(0) }
  end

  describe "#calculate_equivalents" do
    let(:user_balance) { user.user_balance.tap { |ub| ub.update!(total_toman: 100_000_000) } }

    context "with valid rates" do
      it "returns hash with all equivalents" do
        usd_rate = 42_500
        gold_rate = 2_150_000

        result = user_balance.calculate_equivalents(usd_rate, gold_rate)

        expect(result).to be_a(Hash)
        expect(result).to include(:total_toman, :total_usd_equivalent, :total_gold_grams_equivalent)
      end

      it "calculates USD equivalent correctly" do
        usd_rate = 42_500
        gold_rate = 2_150_000

        result = user_balance.calculate_equivalents(usd_rate, gold_rate)

        # 100M / 42500 = 2352.94
        expected_usd = (100_000_000.to_f / usd_rate).round(2)
        expect(result[:total_usd_equivalent]).to eq(expected_usd)
      end

      it "calculates gold gram equivalent correctly" do
        usd_rate = 42_500
        gold_rate = 2_150_000

        result = user_balance.calculate_equivalents(usd_rate, gold_rate)

        # 100M / 2150000 = 46.512
        expected_gold = (100_000_000.to_f / gold_rate).round(3)
        expect(result[:total_gold_grams_equivalent]).to eq(expected_gold)
      end

      it "preserves total_toman in result" do
        usd_rate = 42_500
        gold_rate = 2_150_000

        result = user_balance.calculate_equivalents(usd_rate, gold_rate)

        expect(result[:total_toman]).to eq(100_000_000)
      end
    end

    context "with zero balance" do
      let(:user_balance) { user.user_balance.tap { |ub| ub.update!(total_toman: 0) } }

      it "returns zero equivalents" do
        usd_rate = 42_500
        gold_rate = 2_150_000

        result = user_balance.calculate_equivalents(usd_rate, gold_rate)

        expect(result[:total_toman]).to eq(0)
        expect(result[:total_usd_equivalent]).to eq(0.0)
        expect(result[:total_gold_grams_equivalent]).to eq(0.0)
      end
    end

    context "with different rate values" do
      it "scales equivalents proportionally to rate changes" do
        balance = user.user_balance.tap { |ub| ub.update!(total_toman: 100_000_000) }

        result_low_rate = balance.calculate_equivalents(10_000, 2_150_000)
        result_high_rate = balance.calculate_equivalents(100_000, 2_150_000)

        # With 10x higher rate, USD equivalent should be 10x lower
        expect(result_low_rate[:total_usd_equivalent]).to be > result_high_rate[:total_usd_equivalent]
      end
    end

    context "with very large balances" do
      let(:user_balance) { user.user_balance.tap { |ub| ub.update!(total_toman: 99_999_999_999) } }

      it "handles large amounts without overflow" do
        usd_rate = 42_500
        gold_rate = 2_150_000

        result = user_balance.calculate_equivalents(usd_rate, gold_rate)

        expect(result[:total_usd_equivalent]).to be_positive
        expect(result[:total_gold_grams_equivalent]).to be_positive
      end
    end
  end

  describe "#recalculate!" do
    context "when user has transactions" do
      before do
        # Create income and expense transactions
        create(:transaction, user: user, amount_toman: 100_000_000, transaction_type: "income")
        create(:transaction, user: user, amount_toman: 30_000_000, transaction_type: "expense")
      end

      it "updates total_toman from transactions" do
        user_balance = user.user_balance.tap { |ub| ub.update!(total_toman: 0) }

        user_balance.recalculate!

        # 100M - 30M = 70M
        expect(user_balance.reload.total_toman).to eq(70_000_000)
      end

      it "recalculates equivalents with current rates" do
        # Create current rates
        MarketRate.create!(rate_type: "usd", value_in_toman: 42_500, timestamp: Time.current)
        MarketRate.create!(rate_type: "gold_gram", value_in_toman: 2_150_000, timestamp: Time.current)

        user_balance = user.user_balance.tap { |ub| ub.update!(total_toman: 0) }
        user_balance.recalculate!

        # 70M / 42500 = 1647.06
        expected_usd = (70_000_000.to_f / 42_500).round(2)
        expect(user_balance.reload.total_usd_equivalent).to eq(expected_usd)
      end
    end

    context "when user has no transactions" do
      it "sets balance to zero" do
        user_balance = user.user_balance.tap { |ub| ub.update!(total_toman: 100_000_000) }

        user_balance.recalculate!

        expect(user_balance.reload.total_toman).to eq(0)
      end
    end
  end

  describe "#balance_in_currency" do
    let(:user_balance) { user.user_balance.tap { |ub| ub.update!(total_toman: 100_000_000) } }

    context "for USD conversion" do
      it "converts Toman to USD" do
        rate = 42_500
        result = user_balance.balance_in_currency("usd", rate)

        expected = (100_000_000.to_f / rate).round(2)
        expect(result).to eq(expected)
      end
    end

    context "for Gold conversion" do
      it "converts Toman to gold grams" do
        rate = 2_150_000
        result = user_balance.balance_in_currency("gold_gram", rate)

        expected = (100_000_000.to_f / rate).round(3)
        expect(result).to eq(expected)
      end
    end
  end
end
