# frozen_string_literal: true

class FetchMarketRatesJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("Starting FetchMarketRatesJob...")
    
    success = MarketDataService.fetch_and_store_rates
    
    if success
      Rails.logger.info("Market rates fetched and stored successfully")
    else
      Rails.logger.warn("Failed to fetch market rates")
    end
    
    success
  rescue StandardError => e
    Rails.logger.error("FetchMarketRatesJob failed: #{e.message}")
    false
  end
end
