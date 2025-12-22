# frozen_string_literal: true

# JWT Token management and authentication service
# Handles:
#   - JWT token generation and validation
#   - Token refresh logic
#   - Token expiration and claims

class AuthService
  class InvalidTokenError < StandardError; end
  class TokenExpiredError < StandardError; end

  JWT_ALGORITHM = 'HS256'
  TOKEN_EXPIRY = 7.days

  # Class method wrapper for convenience
  def self.generate_token(user)
    new.generate_token(user)
  end

  def generate_token(user)
    payload = {
      user_id: user.id,
      mobile_number: user.mobile_number,
      iat: Time.now.to_i,
      exp: (Time.now + TOKEN_EXPIRY).to_i
    }

    JWT.encode(payload, jwt_secret, JWT_ALGORITHM)
  end

  def decode_token(token)
    raise InvalidTokenError, 'Token cannot be nil' if token.nil?

    begin
      decoded = JWT.decode(token, jwt_secret, true, algorithm: JWT_ALGORITHM)
      decoded.first
    rescue JWT::ExpiredSignature
      raise TokenExpiredError, 'Token has expired'
    rescue JWT::DecodeError => e
      raise InvalidTokenError, e.message
    end
  end

  def refresh_token(old_token)
    payload = decode_token(old_token)
    user_id = payload['user_id']
    user = User.find(user_id)
    # Sleep to ensure new token has different timestamp (since we use to_i which truncates to seconds)
    sleep(1)
    generate_token(user)
  end

  def token_info(token)
    payload = decode_token(token)
    expires_at = Time.at(payload['exp'])
    expires_in = (payload['exp'] - Time.now.to_i)

    {
      'token' => token,
      'expires_at' => expires_at.iso8601,
      'expires_in' => expires_in,
      'token_type' => 'Bearer'
    }
  end

  def valid_token?(token)
    decode_token(token)
    true
  rescue InvalidTokenError, TokenExpiredError
    false
  end

  private

  def jwt_secret
    ENV['JWT_SECRET'].presence || Rails.application.secret_key_base
  end
end
