# frozen_string_literal: true

class SpendingService
  class << self
    # Calculate spending breakdown by category for current Jalali month
    # Returns array of hashes with category spending data, sorted by amount descending
    def calculate_spending_by_category(user)
      start_date, end_date = current_jalali_month_range

      # Group expenses by category for current month
      spending_by_category = user.transactions
        .where(type: 'expense')
        .where(date: start_date..end_date)
        .group(:category_id)
        .sum(:amount_toman)

      return [] if spending_by_category.empty?

      total_amount = spending_by_category.values.sum

      # Build result array with category information
      result = spending_by_category.map do |category_id, amount|
        category = Category.find(category_id)
        {
          category_id: category.id,
          category_name_fa: category.name_fa,
          category_icon: category.icon_code,
          total_amount: amount,
          percentage: ((amount.to_f / total_amount) * 100).round(2)
        }
      end

      # Sort by amount descending
      result.sort_by { |item| item[:total_amount] }.reverse
    end

    # Get total spending for current Jalali month
    def total_spending_current_month(user)
      start_date, end_date = current_jalali_month_range

      user.transactions
        .where(type: 'expense')
        .where(date: start_date..end_date)
        .sum(:amount_toman)
    end

    # Get current Jalali month range (start_date, end_date)
    # Returns array of [start_date, end_date]
    def current_jalali_month_range
      today = Date.current
      jalali_today = today.to_jalali

      # Get first day of current Jalali month
      start_date = Date.from_jalali(jalali_today.year, jalali_today.month, 1)

      # Get last day of current Jalali month
      # Jalali months have 31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 29/30, 29/30 days
      last_day = if jalali_today.month <= 6
                   31
                 elsif jalali_today.month <= 11
                   30
                 else
                   # Month 12: 29 or 30 depending on leap year
                   is_jalali_leap_year(jalali_today.year) ? 30 : 29
                 end

      end_date = Date.from_jalali(jalali_today.year, jalali_today.month, last_day)

      [start_date, end_date]
    end

    private

    # Check if Jalali year is a leap year
    def is_jalali_leap_year(year)
      # Jalali leap year calculation
      # In a 2820-year cycle, years 1, 5, 9, 13, 17, 22, 26, 30 (in 128-year cycles) are leap
      cycle = year % 2820
      ((cycle * 683) % 2820) < 683
    end
  end
end
