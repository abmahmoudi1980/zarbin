# frozen_string_literal: true

# MarketRate model - Real-time market rates from TGJU API
# Attributes:
#   - rate_type: enum (usd, gold_gram, bahar_coin)
#   - value_in_toman: current rate value
#   - timestamp: when rate was fetched

class MarketRate < ApplicationRecord
  # Validations
  validates :rate_type, presence: true, inclusion: { 
    in: %w(usd gold_gram bahar_coin),
    message: '%{value} is not a valid rate type' 
  }
  validates :value_in_toman, presence: true, numericality: { 
    only_integer: true, 
    greater_than: 0 
  }
  validates :timestamp, presence: true

  # Enums
  enum rate_type: { usd: 'usd', gold_gram: 'gold_gram', bahar_coin: 'bahar_coin' }

  # Scopes
  scope :latest, -> { order(timestamp: :desc).limit(3) }
  scope :for_type, ->(type) { where(rate_type: type) }
  scope :recent, -> { where('timestamp > ?', 1.hour.ago) }

  # Instance Methods

  def self.latest_rates
    %w(usd gold_gram bahar_coin).map { |type| for_type(type).order(timestamp: :desc).first }.compact
  end

  def self.rate_for_type(rate_type)
    for_type(rate_type).order(timestamp: :desc).first
  end

  def self.latest_rate_for(rate_type)
    for_type(rate_type).order(timestamp: :desc).first&.value_in_toman
  end

  def stale?
    timestamp < 5.minutes.ago
  end

  def rate_label
    case rate_type
    when 'usd'
      'USD/Toman'
    when 'gold_gram'
      'Gold (gram)/Toman'
    when 'bahar_coin'
      'Bahar Azadi/Toman'
    end
  end
end
