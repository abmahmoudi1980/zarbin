# frozen_string_literal: true

require "rails_helper"

RSpec.describe SpendingService do
  describe ".calculate_spending_by_category" do
    let(:user) { create(:user) }
    let(:current_month_range) { SpendingService.current_jalali_month_range }

    context "when user has no transactions" do
      it "returns empty array" do
        result = SpendingService.calculate_spending_by_category(user)
        expect(result).to be_an(Array)
        expect(result).to be_empty
      end
    end

    context "when user has expenses in current Jalali month" do
      before do
        food_category = Category.find_by(name_fa: "غذا")
        transport_category = Category.find_by(name_fa: "حمل‌ونقل")

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

      it "returns spending breakdown with all expense categories" do
        result = SpendingService.calculate_spending_by_category(user)

        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
      end

      it "includes correct fields for each category" do
        result = SpendingService.calculate_spending_by_category(user)

        category_data = result.first
        expect(category_data).to include(
          category_id: be_a(String),
          category_name_fa: be_a(String),
          category_icon: be_a(String),
          total_amount: be_a(Integer),
          percentage: be_a(Float)
        )
      end

      it "calculates total amounts correctly" do
        result = SpendingService.calculate_spending_by_category(user)

        food_data = result.find { |c| c[:category_name_fa] == "غذا" }
        expect(food_data[:total_amount]).to eq(5_000_000)

        transport_data = result.find { |c| c[:category_name_fa] == "حمل‌ونقل" }
        expect(transport_data[:total_amount]).to eq(2_000_000)
      end

      it "calculates percentages correctly" do
        result = SpendingService.calculate_spending_by_category(user)
        total = result.sum { |c| c[:total_amount] }

        result.each do |category|
          expected_percentage = (category[:total_amount].to_f / total * 100).round(2)
          expect(category[:percentage]).to eq(expected_percentage)
        end
      end

      it "returns breakdown sorted by amount descending" do
        result = SpendingService.calculate_spending_by_category(user)

        amounts = result.map { |c| c[:total_amount] }
        expect(amounts).to eq(amounts.sort.reverse)
      end

      it "returns only expense transactions" do
        income_category = Category.find_by(name_fa: "سایر")
        
        # Create an income transaction
        Transaction.create!(
          user_id: user.id,
          amount_toman: 10_000_000,
          type: "income",
          date: Date.current,
          category_id: income_category.id
        )

        result = SpendingService.calculate_spending_by_category(user)

        # Should still only have 2 categories (food and transport) with 7M total
        expect(result.sum { |c| c[:total_amount] }).to eq(7_000_000)
      end
    end

    context "when user has transactions in different Jalali months" do
      before do
        food_category = Category.find_by(name_fa: "غذا")

        # Current month transaction
        Transaction.create!(
          user_id: user.id,
          amount_toman: 5_000_000,
          type: "expense",
          date: Date.current,
          category_id: food_category.id
        )

        # Previous month transaction
        Transaction.create!(
          user_id: user.id,
          amount_toman: 10_000_000,
          type: "expense",
          date: 40.days.ago,
          category_id: food_category.id
        )

        # Future month transaction
        Transaction.create!(
          user_id: user.id,
          amount_toman: 3_000_000,
          type: "expense",
          date: 40.days.from_now,
          category_id: food_category.id
        )
      end

      it "only includes transactions from current Jalali month" do
        result = SpendingService.calculate_spending_by_category(user)

        # Should only include current month transaction (5M)
        total = result.sum { |c| c[:total_amount] }
        expect(total).to eq(5_000_000)
      end
    end

    context "when multiple transactions exist in same category" do
      before do
        food_category = Category.find_by(name_fa: "غذا")

        Transaction.create!(
          user_id: user.id,
          amount_toman: 2_000_000,
          type: "expense",
          date: Date.current,
          category_id: food_category.id
        )

        Transaction.create!(
          user_id: user.id,
          amount_toman: 3_000_000,
          type: "expense",
          date: Date.current,
          category_id: food_category.id
        )
      end

      it "sums all amounts for the category" do
        result = SpendingService.calculate_spending_by_category(user)

        expect(result.length).to eq(1)
        expect(result.first[:total_amount]).to eq(5_000_000)
      end
    end

    context "when category has no transactions" do
      it "does not include category in breakdown" do
        food_category = Category.find_by(name_fa: "غذا")

        Transaction.create!(
          user_id: user.id,
          amount_toman: 1_000_000,
          type: "expense",
          date: Date.current,
          category_id: food_category.id
        )

        result = SpendingService.calculate_spending_by_category(user)

        # Only food category should be included
        expect(result.length).to eq(1)
        expect(result.first[:category_name_fa]).to eq("غذا")
      end
    end
  end

  describe ".current_jalali_month_range" do
    it "returns current Jalali month start and end dates" do
      start_date, end_date = SpendingService.current_jalali_month_range

      expect(start_date).to be_a(Date)
      expect(end_date).to be_a(Date)
      expect(start_date <= end_date).to be true
    end

    it "includes today's date in range" do
      start_date, end_date = SpendingService.current_jalali_month_range

      expect(start_date <= Date.current).to be true
      expect(end_date >= Date.current).to be true
    end
  end

  describe ".total_spending_current_month" do
    let(:user) { create(:user) }

    context "when user has no expenses in current month" do
      it "returns 0" do
        total = SpendingService.total_spending_current_month(user)
        expect(total).to eq(0)
      end
    end

    context "when user has expenses in current month" do
      before do
        food_category = Category.find_by(name_fa: "غذا")

        Transaction.create!(
          user_id: user.id,
          amount_toman: 5_000_000,
          type: "expense",
          date: Date.current,
          category_id: food_category.id
        )
      end

      it "returns total expense amount" do
        total = SpendingService.total_spending_current_month(user)
        expect(total).to eq(5_000_000)
      end
    end
  end
end
