# frozen_string_literal: true

require 'digest'

module Api
  module V1
    class RatesController < Api::V1::ApplicationController
      # Rates are public - no authentication needed
      skip_before_action :verify_jwt_token
      before_action :set_rate, only: [:show]

      # GET /api/v1/rates
      # Returns all current market rates - main endpoint for frontend
      def index
        rates = MarketRate.latest_rates
        
        if rates.empty?
          set_cache_headers
          return render_success(
            {
              rates: [],
              timestamp: Time.current.iso8601,
              rates_stale_minutes: nil,
              stale: false
            }
          )
        end

        # Format rates for response
        formatted_rates = rates.map { |rate| format_rate_response(rate) }
        stale_minutes = calculate_stale_minutes(rates.first.timestamp)

        response_data = {
          rates: formatted_rates,
          timestamp: rates.first.timestamp.in_time_zone.iso8601,
          rates_stale_minutes: stale_minutes,
          stale: stale_minutes > 5
        }

        set_cache_headers
        render_success(response_data)
      rescue StandardError => e
        render_error("Failed to fetch rates: #{e.message}", :internal_server_error)
      end

      # GET /api/v1/rates/latest (kept for backward compatibility)
      def latest
        rates = MarketRate.latest_rates
        render json: format_rates(rates)
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # GET /api/v1/rates/:id
      def show
        render json: {
          id: @rate.id,
          rate_type: @rate.rate_type,
          value_in_toman: @rate.value_in_toman,
          rate_label: @rate.rate_label,
          timestamp: @rate.timestamp.in_time_zone.iso8601,
          stale: @rate.stale?
        }
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # GET /api/v1/rates/current/:type
      def current
        rate_type = params[:type]
        rate = MarketRate.rate_for_type(rate_type)

        if rate
          render json: {
            rate_type: rate.rate_type,
            value_in_toman: rate.value_in_toman,
            rate_label: rate.rate_label,
            timestamp: rate.timestamp.in_time_zone.iso8601,
            stale: rate.stale?
          }
        else
          render json: { error: "Rate not found for type: #{rate_type}" }, status: :not_found
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      private

      def set_rate
        @rate = MarketRate.find(params[:id])
      end

      def format_rate_response(rate)
        {
          rate_type: rate.rate_type,
          value_in_toman: rate.value_in_toman,
          label: rate.rate_label,
          timestamp: rate.timestamp.in_time_zone.iso8601,
          stale: rate.stale?,
          change_percent: calculate_change_percent(rate),
          change_direction: calculate_change_direction(rate)
        }
      end

      def format_rates(rates)
        {
          rates: rates.map do |rate|
            {
              id: rate.id,
              rate_type: rate.rate_type,
              value_in_toman: rate.value_in_toman,
              rate_label: rate.rate_label,
              timestamp: rate.timestamp.in_time_zone.iso8601,
              stale: rate.stale?
            }
          end,
          last_updated: rates.first&.timestamp&.in_time_zone&.iso8601
        }
      end

      def calculate_change_percent(rate)
        # Get previous rate from 1 hour ago for comparison
        previous = MarketRate.where(rate_type: rate.rate_type)
                              .where('timestamp < ?', 1.hour.ago)
                              .order(timestamp: :desc)
                              .first

        return 0 unless previous.present?

        change = rate.value_in_toman - previous.value_in_toman
        (change.to_f / previous.value_in_toman * 100).round(2)
      end

      def calculate_change_direction(rate)
        percent = calculate_change_percent(rate)
        return 'stable' if percent.zero?
        percent > 0 ? 'up' : 'down'
      end

      def calculate_stale_minutes(timestamp)
        ((Time.current - timestamp) / 60).ceil
      end

      def set_cache_headers
        # Cache rates for 5 minutes as they refresh every 5 minutes
        response.headers['Cache-Control'] = 'public, max-age=300'
        response.headers['ETag'] = generate_etag
      end

      def generate_etag
        rates = MarketRate.latest_rates
        Digest::MD5.hexdigest(rates.map { |r| "#{r.rate_type}:#{r.value_in_toman}:#{r.timestamp}" }.join('|'))
      end
    end
  end
end
