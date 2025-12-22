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
  # Allow legacy/consumer code that uses `type` to map to `transaction_type`
  alias_attribute :type, :transaction_type
  # Allow specs and older callers to use `date` instead of `transaction_date`
  alias_attribute :date, :transaction_date
  # Allow specs to use singular `note` while DB column is `notes`
  alias_attribute :note, :notes
  # Associations
  belongs_to :user
  belongs_to :category, optional: true

  # Validations
  validates :user, presence: true
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
  validate :validate_jalali_date_format
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
  enum :transaction_type, { income: 'income', expense: 'expense' }

  # Callbacks
  before_validation :set_default_category
  before_validation :capture_rates
  before_create :capture_rates
  after_save :update_user_balance

  # Scopes
  scope :income_only, -> { where(transaction_type: :income) }
  scope :expense_only, -> { where(transaction_type: :expense) }
  scope :ordered, -> { order(transaction_date: :desc, created_at: :desc) }
  scope :sorted_by_date, -> { order(transaction_date: :desc, created_at: :desc) }
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
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

  def validate_jalali_date_format
    return if transaction_date.blank?
    
    # Only validate strings - Date/Time objects will be converted by ActiveRecord
    return unless transaction_date.is_a?(String)
    
    # Allow ISO format dates (YYYY-MM-DD) which is what Date.to_s produces
    if transaction_date.match?(/^\d{4}-\d{2}-\d{2}$/)
      validate_no_future_date(transaction_date)
      return
    end
    
    # Allow ISO format with timestamps (YYYY-MM-DD HH:MM:SS) from Time/DateTime
    if transaction_date.match?(/^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}/)
      validate_no_future_date(transaction_date)
      return
    end

    # Check Jalali format YYYY/MM/DD for strings
    unless transaction_date.match?(/^\d{4}\/\d{2}\/\d{2}$/)
      errors.add(:transaction_date, 'must be in YYYY/MM/DD format')
      return
    end

    # Parse and validate Jalali date
    year, month, day = transaction_date.split('/').map(&:to_i)
    
    # Validate month (1-12)
    if month < 1 || month > 12
      errors.add(:transaction_date, 'invalid Jalali month')
      return
    end
    
    # Validate day based on month
    max_day = if month <= 6
                31
              elsif month <= 11
                30
              else
                29 # Month 12, simplified (doesn't account for leap years)
              end
    
    if day < 1 || day > max_day
      errors.add(:transaction_date, "invalid day for Jalali month #{month}")
    end
    
    # Validate no future dates
    begin
      date_obj = Date.parse(transaction_date)
      validate_no_future_date(date_obj)
    rescue ArgumentError
      # Date parsing failed, let other validations catch it
    end
  end

  def validate_no_future_date(date_value)
    date_obj = case date_value
               when String
                 Date.parse(date_value)
               when Date, Time, DateTime
                 date_value.to_date
               else
                 nil
               end

    return unless date_obj

    if date_obj > Date.current
      errors.add(:transaction_date, "cannot be in the future (max date: #{Date.current.strftime('%Y-%m-%d')})")
    end
  end

  def set_default_category
    self.category ||= Category.other
  end

  def capture_rates
    self.usd_rate_at_creation ||= MarketRate.latest_rate_for('usd') || 42500
    self.gold_rate_at_creation ||= MarketRate.latest_rate_for('gold_gram') || 2_150_000
  end

  def update_user_balance
    user.user_balance&.recalculate!
  end
end
