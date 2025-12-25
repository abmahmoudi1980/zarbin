# frozen_string_literal: true

# Schedule recurring jobs on Rails startup
# This file runs after Solid Queue is initialized

if defined?(Solid::Queue)
  # Schedule FetchMarketRatesJob to run every 5 minutes via solid_queue.yml recurring config
  # Only during market hours (9 AM - 4 PM Iran Time)
  class MarketRatesScheduler
    def self.schedule
      # Recurring jobs are configured in config/solid_queue.yml
      # No manual scheduling needed
      Rails.logger.info("Market rates scheduler initialized - using Solid Queue recurring jobs")
    end
  end

  # Initialize scheduler on startup
  MarketRatesScheduler.schedule
end
