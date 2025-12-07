# frozen_string_literal: true

module Api
  module V1
    class DashboardController < ApplicationController
      before_action :authenticate_user!

      # GET /api/v1/dashboard
      # Returns the authenticated user's net worth dashboard with balance and equivalents
      def show
        user = current_user
        user_balance = user.user_balance || create_default_balance(user)

        # Get current market rates
        usd_rate = MarketRate.latest_rate_for("usd")
        gold_rate = MarketRate.latest_rate_for("gold_gram")

        # Calculate equivalents with current rates
        equivalents = user_balance.calculate_equivalents(usd_rate || 42_500, gold_rate || 2_150_000)

        render json: {
          total_toman: equivalents[:total_toman],
          total_usd_equivalent: equivalents[:total_usd_equivalent],
          total_gold_grams_equivalent: equivalents[:total_gold_grams_equivalent],
          last_updated: format_jalali_timestamp(Time.current)
        }, status: :ok
      rescue StandardError => e
        Rails.logger.error("Dashboard error for user #{user.id}: #{e.message}")
        render json: { error: "Failed to load dashboard", message: e.message }, status: :internal_server_error
      end

      private

      def create_default_balance(user)
        UserBalance.create!(
          user_id: user.id,
          total_toman: 0,
          total_usd_equivalent: 0.0,
          total_gold_grams_equivalent: 0.0
        )
      end

      def format_jalali_timestamp(time)
        # Convert Gregorian datetime to Jalali format (YYYY/MM/DD HH:MM:SS)
        RateFormatterService.format_jalali_datetime(time) + ":#{time.strftime('%S')}"
      end
    end
  end
end
