# frozen_string_literal: true

# Base Application Controller
# Handles:
#   - JWT authentication for API requests
#   - Error handling and responses
#   - Request/response formatting

class ApplicationController < ActionController::API
  before_action :authenticate_request!

  attr_reader :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from StandardError, with: :internal_error

  private

  def authenticate_request!
    token = extract_token_from_request

    unless token
      Rails.logger.warn("Authentication failed: Authorization header missing from #{request.remote_ip}")
      render json: { 
        success: false, 
        error: 'Authorization header missing' 
      }, status: :unauthorized
      return
    end

    auth_service = AuthService.new
    
    begin
      payload = auth_service.decode_token(token)
      @current_user = User.find(payload['user_id'])
      
      # Log successful authentication
      Rails.logger.info("Successful authentication: User #{@current_user.id} from #{request.remote_ip}")
    rescue AuthService::InvalidTokenError
      Rails.logger.warn("Authentication failed: Invalid token from #{request.remote_ip}")
      render json: { 
        success: false, 
        error: 'Invalid token' 
      }, status: :unauthorized
    rescue AuthService::TokenExpiredError
      Rails.logger.warn("Authentication failed: Token expired from #{request.remote_ip}")
      render json: { 
        success: false, 
        error: 'Token expired' 
      }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn("Authentication failed: User not found from #{request.remote_ip}")
      render json: { 
        success: false, 
        error: 'User not found' 
      }, status: :unauthorized
    end
  end

  def extract_token_from_request
    auth_header = request.headers['Authorization']
    return nil unless auth_header

    # Extract token from "Bearer <token>"
    auth_header.split(' ').last
  end

  def record_not_found(exception)
    render json: {
      success: false,
      error: "#{exception.model} not found"
    }, status: :not_found
  end

  def parameter_missing(exception)
    render json: {
      success: false,
      error: "Missing required parameter: #{exception.param}"
    }, status: :unprocessable_entity
  end

  def internal_error(exception)
    Rails.logger.error("Internal error: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))

    render json: {
      success: false,
      error: 'Internal server error'
    }, status: :internal_server_error
  end
end
