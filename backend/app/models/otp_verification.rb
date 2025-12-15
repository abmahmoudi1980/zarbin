# frozen_string_literal: true

# OtpVerification model - One-time password verification
# Attributes:
#   - mobile_number: Iranian mobile number
#   - otp_code: 6-digit OTP code
#   - expires_at: expiration timestamp (10 minutes)
#   - attempts: attempt counter (max 3)
#   - verified: boolean flag
 #   - is_used: boolean flag

class OtpVerification < ApplicationRecord
  # Validations
  validates :mobile_number, presence: true, format: { 
    with: /\A09\d{9}\z/, 
    message: 'must be a valid Iranian mobile number' 
  }
  validates :otp_code, presence: true, format: { 
    with: /\A\d{6}\z/, 
    message: 'must be exactly 6 digits' 
  }
  validates :expires_at, presence: true
  validates :attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :valid, -> { where('expires_at > ?', Time.current).where(verified: false).where(is_used: false) }
  scope :for_number, ->(number) { where(mobile_number: number) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  # Instance Methods

  def self.generate_otp(mobile_number)
    code = rand(100000..999999)
    expires_at = ENV.fetch('OTP_EXPIRY_MINUTES', 10).to_i.minutes.from_now

    where(mobile_number: mobile_number).where(is_used: false).update_all(is_used: true)

    create(
      mobile_number: mobile_number,
      otp_code: code,
      expires_at: expires_at,
      attempts: 0
    )
  end

  def expired?
    expires_at < Time.current
  end

  def verify(code)
    return false if expired?
    return false if attempts >= max_attempts

    if otp_code.to_s == code.to_s
      update(verified: true)
      true
    else
      increment(:attempts)
      false
    end
  end

  def attempts_remaining
    max_attempts - attempts
  end

  def max_attempts
    ENV.fetch('OTP_MAX_ATTEMPTS', 3).to_i
  end

  private

  def generate_otp_code
    self.otp_code = rand(100000..999999)
    self.expires_at = ENV.fetch('OTP_EXPIRY_MINUTES', 10).to_i.minutes.from_now
  end
end
