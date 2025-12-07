# frozen_string_literal: true

class MarketDataService
  TGJU_API_BASE = "https://api.tgju.org"
  RATE_TYPES = {
    usd: "price_usd",
    gold_gram: "price_gold_grams",
    bahar_coin: "price_bahar_azadi"
  }.freeze
  
  # Cache expiry: 5 minutes
  CACHE_EXPIRY = 5.minutes
  CACHE_KEY = "market_rates:latest"

  class << self
    def fetch_and_store_rates
      rates_data = fetch_rates_from_tgju
      return false if rates_data.blank?

      store_rates(rates_data)
      # Invalidate cache after new rates are stored
      Rails.cache.delete(CACHE_KEY)
      true
    rescue StandardError => e
      Rails.logger.error("Error fetching market rates: #{e.message}")
      false
    end

    def get_current_rates
      # Try to get from cache first
      cached = Rails.cache.read(CACHE_KEY)
      return cached if cached.present?

      # Fetch from database and cache
      latest = MarketRate.latest_rates
      rates_hash = {
        usd_rate: latest.find { |r| r.rate_type == "usd" }&.value_in_toman,
        gold_rate: latest.find { |r| r.rate_type == "gold_gram" }&.value_in_toman,
        bahar_coin_rate: latest.find { |r| r.rate_type == "bahar_coin" }&.value_in_toman,
        timestamp: latest.first&.timestamp
      }
      
      # Store in cache with 5-minute expiry
      Rails.cache.write(CACHE_KEY, rates_hash, expires_in: CACHE_EXPIRY)
      
      rates_hash
    end

    def get_rate(rate_type)
      rate = MarketRate.rate_for_type(rate_type)
      return nil if rate.blank?

      {
        rate_type: rate.rate_type,
        value_in_toman: rate.value_in_toman,
        label: rate.rate_label,
        timestamp: rate.timestamp,
        stale: rate.stale?
      }
    end

    def convert_to_currency(amount_toman, target_currency)
      rate = MarketRate.rate_for_type(target_currency)
      return nil if rate.blank?

      {
        amount: (amount_toman.to_f / rate.value_in_toman).round(2),
        original_amount: amount_toman,
        currency: target_currency,
        rate: rate.value_in_toman,
        timestamp: rate.timestamp
      }
    end

    private

    def fetch_rates_from_tgju
      response = fetch_json("#{TGJU_API_BASE}/v2/live/usd")
      return nil if response.blank?

      rates_hash = response.dig("data") || {}
      {
        usd_rate: rates_hash.dig("usd", "p") || 0,
        gold_rate: rates_hash.dig("gold_grams", "p") || 0,
        bahar_coin_rate: rates_hash.dig("bahar_azadi", "p") || 0
      }
    rescue StandardError => e
      Rails.logger.error("TGJU API fetch error: #{e.message}")
      nil
    end

    def store_rates(rates_data)
      timestamp = Time.current

      [
        { rate_type: "usd", value: rates_data[:usd_rate] },
        { rate_type: "gold_gram", value: rates_data[:gold_rate] },
        { rate_type: "bahar_coin", value: rates_data[:bahar_coin_rate] }
      ].each do |rate_info|
        MarketRate.create(
          rate_type: rate_info[:rate_type],
          value_in_toman: rate_info[:value],
          timestamp: timestamp
        )
      end
    end

    def fetch_json(url)
      require "net/http"
      require "json"

      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      
      request = Net::HTTP::Get.new(uri.request_uri)
      request["User-Agent"] = "Zarbin/1.0"
      
      response = http.request(request)
      JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
    rescue StandardError => e
      Rails.logger.error("HTTP request failed: #{e.message}")
      nil
    end
  end
end
