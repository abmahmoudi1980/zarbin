# frozen_string_literal: true

# API v1 Authentication Controller
# Endpoints:
#   - POST /api/v1/auth/register - User registration with mobile + password
#   - POST /api/v1/auth/verify-otp - OTP verification to activate account
#   - POST /api/v1/auth/login - User login with JWT token generation
#   - POST /api/v1/auth/refresh - Token refresh for 7-day sessions

module Api
  module V1
    class AuthController < ApplicationController
      # Public endpoints, no authentication required for register, verify_otp, login
      skip_before_action :authenticate_request!, only: [:register, :verify_otp, :login]

      # POST /api/v1/auth/register
      # Register new user with Iranian mobile number and password
      def register
        @user = User.new(register_params)
        
        unless validate_password!(register_params[:password])
          Rails.logger.warn("[AUTH] Registration failed - invalid password format for #{register_params[:mobile_number]}")
          return render json: error_response('Invalid password format'), status: :unprocessable_entity
        end

        unless validate_mobile_number!(register_params[:mobile_number])
          Rails.logger.warn("[AUTH] Registration failed - invalid mobile number format: #{register_params[:mobile_number]}")
          return render json: error_response('Invalid mobile number format'), status: :unprocessable_entity
        end

        if @user.save
          Rails.logger.info("[AUTH] User registered successfully: #{@user.mobile_number}")
          # Send OTP
          otp_service = OtpService.new
          otp_service.send_otp(@user.mobile_number)

          render json: success_response(
            { mobile_number: @user.mobile_number, account_status: @user.account_status },
            'OTP sent successfully. Please verify to activate your account.'
          ), status: :created
        else
          Rails.logger.warn("[AUTH] Registration failed for #{register_params[:mobile_number]}: #{@user.errors.full_messages.join(', ')}")
          render json: error_response(@user.errors.full_messages.first), status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error("[AUTH] Registration error for #{register_params[:mobile_number]}: #{e.message}")
        render json: error_response('Registration failed'), status: :unprocessable_entity
      end

      # POST /api/v1/auth/verify-otp
      # Verify OTP and activate account
      def verify_otp
        mobile_number = verify_otp_params[:mobile_number]
        otp_code = verify_otp_params[:otp_code]

        user = User.find_by(mobile_number:)
        
        unless user
          Rails.logger.warn("[AUTH] OTP verification failed - user not found: #{mobile_number}")
          return render json: error_response('User not found'), status: :unauthorized
        end

        otp_service = OtpService.new
        
        unless otp_service.verify_otp(mobile_number, otp_code)
          Rails.logger.warn("[AUTH] OTP verification failed - invalid/expired OTP for: #{mobile_number}")
          return render json: error_response('Invalid or expired OTP'), status: :unauthorized
        end

        # Activate user
        user.update(account_status: :active)
        Rails.logger.info("[AUTH] User activated successfully: #{mobile_number}")

        # Generate token
        auth_service = AuthService.new
        token = auth_service.generate_token(user)
        token_info = auth_service.token_info(token)

        render json: success_response(
          user.as_json(only: [:id, :mobile_number, :account_status]).merge(token_info),
          'OTP verified successfully'
        ), status: :ok
      rescue StandardError => e
        Rails.logger.error("[AUTH] OTP verification error for #{mobile_number}: #{e.message}")
        render json: error_response('OTP verification failed'), status: :unauthorized
      end

      # POST /api/v1/auth/login
      # User login with mobile number and password
      def login
        mobile_number = login_params[:mobile_number]
        password = login_params[:password]

        user = User.find_by(mobile_number:)
        
        unless user
          Rails.logger.warn("[AUTH] Login failed - user not found: #{mobile_number}")
          return render json: error_response('Invalid credentials'), status: :unauthorized
        end

        # Check if account is locked
        if user.account_locked?
          unlock_time = user.locked_until.strftime('%H:%M')
          Rails.logger.warn("[AUTH] Login blocked - account locked: #{mobile_number} until #{unlock_time}")
          return render json: error_response("Account is locked until #{unlock_time}"), status: :forbidden
        end

        # Authenticate
        unless user.authenticate(password)
          Rails.logger.warn("[AUTH] Login failed - invalid credentials for: #{mobile_number} (attempt #{user.failed_login_attempts + 1}/5)")
          return render json: error_response('Invalid credentials'), status: :unauthorized
        end

        Rails.logger.info("[AUTH] User logged in successfully: #{mobile_number}")

        # Generate token
        auth_service = AuthService.new
        token = auth_service.generate_token(user)
        token_info = auth_service.token_info(token)

        render json: success_response(
          user.as_json(only: [:id, :mobile_number, :account_status]).merge(token_info),
          'Login successful'
        ), status: :ok
      rescue StandardError => e
        Rails.logger.error("[AUTH] Login error for #{mobile_number}: #{e.message}")
        render json: error_response('Login failed'), status: :unauthorized
      end

      # POST /api/v1/auth/refresh
      # Refresh JWT token for continued session
      def refresh
        token = request.headers['Authorization']&.split(' ')&.last

        unless token
          Rails.logger.warn("[AUTH] Token refresh failed - no token provided")
          return render json: error_response('No token provided'), status: :unauthorized
        end

        auth_service = AuthService.new
        
        begin
          new_token = auth_service.refresh_token(token)
          token_info = auth_service.token_info(new_token)
          
          # Log success without exposing token
          payload = auth_service.decode_token(new_token)
          user_id = payload['user_id']
          Rails.logger.info("[AUTH] Token refreshed successfully for user_id: #{user_id}")

          render json: success_response(token_info, 'Token refreshed'), status: :ok
        rescue AuthService::InvalidTokenError => e
          Rails.logger.warn("[AUTH] Token refresh failed - invalid token: #{e.message}")
          render json: error_response('Invalid token'), status: :unauthorized
        rescue AuthService::TokenExpiredError => e
          Rails.logger.warn("[AUTH] Token refresh failed - token expired: #{e.message}")
          render json: error_response('Token expired'), status: :unauthorized
        end
      rescue StandardError => e
        Rails.logger.error("[AUTH] Token refresh error: #{e.message}")
        render json: error_response('Token refresh failed'), status: :unauthorized
      end

      private

      def register_params
        params.require(:auth).permit(:mobile_number, :password)
      end

      def verify_otp_params
        params.require(:otp).permit(:mobile_number, :otp_code)
      end

      def login_params
        params.require(:auth).permit(:mobile_number, :password)
      end

      def validate_password!(password)
        # Password must be:
        # - At least 8 characters
        # - At least 1 number
        return false if password.blank? || password.length < 8
        password.match?(/\d/)
      end

      def validate_mobile_number!(mobile_number)
        # Iranian mobile number: 09XXXXXXXXX
        mobile_number.match?(/\A09\d{9}\z/)
      end

      def success_response(data = {}, message = 'Success')
        {
          success: true,
          message:,
          data:
        }
      end

      def error_response(message)
        {
          success: false,
          error: message
        }
      end
    end
  end
end
