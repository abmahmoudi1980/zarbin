# frozen_string_literal: true

# UserBalance model - User's total balance tracking
# Attributes:
#   - user_id: belongs to User
#   - total_toman: total amount in Toman (sum of transactions)
#   - total_usd_equivalent: USD equivalent at current rate
#   - total_gold_grams_equivalent: Gold grams equivalent at current rate

class UserBalance < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :user_id, presence: true, uniqueness: true
  validates :total_toman, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_usd_equivalent, numericality: { only_float: true, greater_than_or_equal_to: 0.0 }
  validates :total_gold_grams_equivalent, numericality: { only_float: true, greater_than_or_equal_to: 0.0 }

  # Callbacks
  before_save :validate_consistency

  # Instance Methods

  def recalculate!
    total = Transaction.total_for_user(user_id)
    
    current_usd_rate = MarketRate.latest_rate_for('usd') || 42_500
    current_gold_rate = MarketRate.latest_rate_for('gold_gram') || 2_150_000

    update(
      total_toman: total,
      total_usd_equivalent: calculate_usd_equivalent(total, current_usd_rate),
      total_gold_grams_equivalent: calculate_gold_equivalent(total, current_gold_rate)
    )
  end

  def calculate_equivalents(usd_rate, gold_rate)
    {
      total_toman: total_toman,
      total_usd_equivalent: calculate_usd_equivalent(total_toman, usd_rate),
      total_gold_grams_equivalent: calculate_gold_equivalent(total_toman, gold_rate)
    }
  end

  def balance_in_currency(currency_type, rate)
    case currency_type
    when 'usd'
      (total_toman.to_f / rate).round(2)
    when 'gold_gram'
      (total_toman.to_f / rate).round(3)
    else
      total_toman
    end
  end

  private

  def calculate_usd_equivalent(amount, rate)
    (amount.to_f / rate).round(2)
  end

  def calculate_gold_equivalent(amount, rate)
    (amount.to_f / rate).round(3)
  end

  def validate_consistency
    # Ensure equivalents are consistent with total_toman
    return if total_toman.zero?

    current_usd_rate = MarketRate.latest_rate_for('usd') || 42_500
    current_gold_rate = MarketRate.latest_rate_for('gold_gram') || 2_150_000

    expected_usd = calculate_usd_equivalent(total_toman, current_usd_rate)
    expected_gold = calculate_gold_equivalent(total_toman, current_gold_rate)

    # Keep stored equivalents aligned with current total_toman.
    self.total_usd_equivalent = expected_usd
    self.total_gold_grams_equivalent = expected_gold
  end
end
