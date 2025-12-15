class CurrencyService
  class ExchangeRateNotAvailable < StandardError; end

  RATE_TYPE_MAP = {
    'USD' => 'usd',
    'usd' => 'usd',
    'Gold' => 'gold_gram',
    'gold_gram' => 'gold_gram',
    'BaharCoin' => 'bahar_coin',
    'bahar_coin' => 'bahar_coin'
  }.freeze

  # Converts Toman to USD using the current USD exchange rate
  def self.toman_to_usd(amount_toman)
    rate = get_current_rate('USD')
    raise ExchangeRateNotAvailable, 'USD exchange rate not available' unless rate.present?

    (amount_toman.to_f / rate).round(2)
  end

  # Converts Toman to gold grams using the current gold exchange rate
  def self.toman_to_gold_grams(amount_toman)
    rate = get_current_rate('Gold')
    raise ExchangeRateNotAvailable, 'Gold exchange rate not available' unless rate.present?

    (amount_toman.to_f / rate).round(3)
  end

  # Retrieves the current exchange rate for a specific rate_type
  def self.get_current_rate(rate_type)
    normalized = RATE_TYPE_MAP.fetch(rate_type, rate_type)
    MarketRate.latest_rate_for(normalized)
  end

  # Records the exchange rate at transaction creation time for historical accuracy
  def self.record_transaction_rate(rate_type)
    rate = get_current_rate(rate_type)
    raise ExchangeRateNotAvailable, "#{rate_type} exchange rate not available" unless rate.present?

    rate
  end

  # Calculates equivalent amount at a historical rate
  def self.equivalent_at_rate(amount_toman, rate)
    (amount_toman.to_f / rate).round(2)
  end

  # Bulk converts multiple amounts at once
  def self.bulk_convert(amounts, rate_type = 'USD')
    rate = get_current_rate(rate_type)
    raise ExchangeRateNotAvailable, "#{rate_type} exchange rate not available" unless rate.present?

    amounts.map { |amount| (amount.to_f / rate).round(2) }
  end

  # Converts a date to Jalali format (YYYY/MM/DD)
  def self.to_jalali_date(gregorian_date)
    # Implementation using shamsi_date gem or equivalent
    # For now, assume the date is already in Jalali format from input
    gregorian_date
  end
end
