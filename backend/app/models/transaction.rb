# frozen_string_literal: true

# Transaction model - Income/expense transactions
# Attributes:
#   - user_id: belongs to User
#   - amount_toman: amount in Toman (>0, <=99,999,999,999)
#   - transaction_type: enum (income, expense)
#   - category_id: belongs to Category
#   - transaction_date: Jalali date (YYYY/MM/DD)
#   - usd_rate_at_creation: exchange rate at creation time
#   - gold_rate_at_creation: gold rate at creation time
#   - notes: optional notes (max 500 chars)

class Transaction < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :category, optional: true

  # Validations
  validates :user_id, presence: true
  validates :amount_toman, presence: true, numericality: { 
    only_integer: true, 
    greater_than: 0,
    less_than_or_equal_to: 99_999_999_999,
    message: 'must be between 1 and 99,999,999,999 Toman' 
  }
  validates :transaction_type, presence: true, inclusion: { 
    in: %w(income expense),
    message: '%{value} is not a valid transaction type' 
  }
  validates :transaction_date, presence: true
  validates :notes, length: { maximum: 500, message: 'cannot exceed 500 characters' }
  validates :usd_rate_at_creation, presence: true, numericality: { 
    only_float: true, 
    greater_than: 0 
  }
  validates :gold_rate_at_creation, presence: true, numericality: { 
    only_integer: true,
    greater_than: 0 
  }

  # Enums
  enum transaction_type: { income: 'income', expense: 'expense' }

  # Callbacks
  before_validation :set_default_category
  before_create :capture_rates
  after_save :update_user_balance

  # Scopes
  scope :income_only, -> { where(transaction_type: :income) }
  scope :expense_only, -> { where(transaction_type: :expense) }
  scope :ordered, -> { order(transaction_date: :desc, created_at: :desc) }
  scope :for_jalali_month, ->(year, month) { 
    where('transaction_date >= ? AND transaction_date < ?',
          "#{year}/#{format('%02d', month)}/01",
          "#{year}/#{format('%02d', month + 1)}/01")
  }

  # Instance Methods

  def amount_usd_equivalent
    (amount_toman.to_f / usd_rate_at_creation).round(2)
  end

  def amount_gold_grams_equivalent
    (amount_toman.to_f / gold_rate_at_creation).round(2)
  end

  def self.total_for_user(user_id)
    income = income_only.where(user_id: user_id).sum(:amount_toman)
    expense = expense_only.where(user_id: user_id).sum(:amount_toman)
    income - expense
  end

  def self.total_expense_for_user_in_month(user_id, year, month)
    expense_only
      .where(user_id: user_id)
      .for_jalali_month(year, month)
      .sum(:amount_toman)
  end

  private

  def set_default_category
    self.category ||= Category.other
  end

  def capture_rates
    self.usd_rate_at_creation ||= MarketRate.rate_for_type('usd') || 42500
    self.gold_rate_at_creation ||= MarketRate.rate_for_type('gold_gram') || 2150000
  end

  def update_user_balance
    user.user_balance&.recalculate!
  end
end
