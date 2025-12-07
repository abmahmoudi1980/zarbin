# ErrorHandler - Shared error handling logic
# frozen_string_literal: true

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  end

  private

  def handle_error(exception)
    Rails.logger.error("Error: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))

    render json: { error: 'Internal server error' }, status: :internal_server_error
  end

  def handle_not_found(exception)
    render json: { error: 'Not found' }, status: :not_found
  end

  def handle_validation_error(exception)
    errors = exception.record.errors.to_hash
    render json: { error: 'Validation failed', errors: errors }, status: :unprocessable_entity
  end
end
