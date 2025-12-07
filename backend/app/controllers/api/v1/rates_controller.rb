# frozen_string_literal: true

module Api
  module V1
    class RatesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_rate, only: [:show]

      # GET /api/v1/rates/latest
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
          timestamp: @rate.timestamp,
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
            timestamp: rate.timestamp,
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

      def format_rates(rates)
        {
          rates: rates.map do |rate|
            {
              id: rate.id,
              rate_type: rate.rate_type,
              value_in_toman: rate.value_in_toman,
              rate_label: rate.rate_label,
              timestamp: rate.timestamp,
              stale: rate.stale?
            }
          end,
          last_updated: rates.first&.timestamp
        }
      end
    end
  end
end
