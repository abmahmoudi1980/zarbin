# frozen_string_literal: true

# Rate Limiter Middleware
# Prevents abuse by limiting requests per IP address
# Configuration: 100 requests per minute per IP

class RateLimiterMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    ip = request.ip || request.remote_ip || '0.0.0.0'
    
    # Skip rate limiting for health checks
    if request.path == '/health' || request.path == '/api/health'
      return @app.call(env)
    end

    # Check rate limit
    key = "rate_limit:#{ip}"
    count = Rails.cache.read(key) || 0
    
    if count >= 100  # 100 requests per minute
      [429, { 'Content-Type' => 'application/json' }, 
       [{ error: 'Too many requests. Please try again later.' }.to_json]]
    else
      Rails.cache.increment(key, 1, expires_in: 1.minute)
      @app.call(env)
    end
  end
end

# Add middleware to Rails stack
Rails.application.config.middleware.use RateLimiterMiddleware
