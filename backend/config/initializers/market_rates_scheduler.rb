# frozen_string_literal: true

# Schedule recurring jobs on Rails startup
# This file runs after Solid Queue is initialized

if defined?(Solid::Queue)
  # Schedule FetchMarketRatesJob to run every 5 minutes
  # Only during market hours (9 AM - 4 PM Iran Time)
  class MarketRatesScheduler
    def self.schedule
      # For MVP, schedule the job to run every 5 minutes
      # In production, you might want to limit this to market hours only
      
      # Use Solid Queue's recurring job pattern if available
      # For now, rely on external cron or job enqueueing mechanism
      Rails.logger.info("Market rates scheduler initialized")
    end
  end

  # Initialize scheduler on startup
  MarketRatesScheduler.schedule
end
