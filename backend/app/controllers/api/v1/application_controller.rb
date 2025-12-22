# ApplicationController - Base controller for all API controllers
# frozen_string_literal: true

module Api
  module V1
    class ApplicationController < ActionController::API
      include ErrorHandler

      # Ensure auth endpoints are excluded from JWT verification.
      # Use `except` on the before_action to avoid referencing actions that
      # do not exist on other controllers (which can raise under Rails 7.1+).
      before_action :verify_jwt_token, except: [:register, :login, :verify_otp]

      attr_reader :current_user

      protected

      def verify_jwt_token
        # Allow unauthenticated access to auth endpoints (register/login/verify_otp)
        return if %w[register login verify_otp].include?(action_name)
        token = extract_token_from_headers
        return render_unauthorized('Token missing') unless token

        begin
          decoded = decode_jwt(token)
          @current_user = User.find(decoded['user_id'])
          return render_unauthorized('User not found') unless @current_user
        rescue JWT::DecodeError => e
          render_unauthorized("Invalid token: #{e.message}")
        rescue StandardError => e
          render_unauthorized("Authentication failed: #{e.message}")
        end
      end

      def extract_token_from_headers
        auth_header = request.headers['Authorization']
        return nil unless auth_header

        # Extract "Bearer <token>"
        auth_header.split(' ').last if auth_header.start_with?('Bearer ')
      end

      def decode_jwt(token)
        JWT.decode(token, jwt_secret, true, { algorithm: 'HS256' })[0]
      end

      def jwt_secret
        @jwt_secret ||= ENV['JWT_SECRET'] || Rails.application.secrets.jwt_secret
      end

      def render_success(data = {}, status = :ok)
        render json: data, status: status
      end

      def render_error(message, status = :unprocessable_entity, errors = nil)
        payload = { error: message }
        payload[:errors] = errors if errors.present?
        render json: payload, status: status
      end

      def render_unauthorized(message = 'Unauthorized')
        render_error(message, :unauthorized)
      end

      def render_not_found(message = 'Not found')
        render_error(message, :not_found)
      end
    end
  end
end
