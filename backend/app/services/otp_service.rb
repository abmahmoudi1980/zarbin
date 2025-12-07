# frozen_string_literal: true

# OTP generation and verification service
# Handles:
#   - OTP code generation (6 digits)
#   - OTP storage with expiry
#   - OTP verification with validation
#   - Invalidation of previous OTPs

class OtpService
  class OtpError < StandardError; end

  OTP_LENGTH = 6
  OTP_EXPIRY = 10.minutes
  MAX_ATTEMPTS = 5

  def generate_otp
    Array.new(OTP_LENGTH) { rand(0..9) }.join
  end

  def send_otp(mobile_number)
    # Invalidate previous OTPs
    OtpVerification.where(mobile_number:).update_all(is_used: true)

    # Generate new OTP
    otp_code = generate_otp
    expires_at = Time.current + OTP_EXPIRY

    # Create OTP record
    otp_verification = OtpVerification.create!(
      mobile_number:,
      otp_code:,
      expires_at:,
      is_used: false,
      attempts: 0
    )

    # Send SMS
    send_sms(mobile_number, otp_code)

    otp_verification
  rescue StandardError => e
    raise OtpError, "Failed to send OTP: #{e.message}"
  end

  def verify_otp(mobile_number, otp_code)
    otp_verification = OtpVerification.find_by(
      mobile_number:,
      otp_code:
    )

    return false if otp_verification.blank?

    # Check if expired
    return false if otp_verification.expires_at < Time.current

    # Check if already used
    return false if otp_verification.is_used

    # Check attempts
    if otp_verification.attempts >= MAX_ATTEMPTS
      otp_verification.update(is_used: true)
      return false
    end

    # Mark as used
    otp_verification.update(is_used: true)
    true
  rescue StandardError => e
    Rails.logger.error("OTP verification failed: #{e.message}")
    false
  end

  def verify_otp_with_attempts(mobile_number, otp_code)
    otp_verification = OtpVerification.find_by(mobile_number:)
    return false if otp_verification.blank?

    if verify_otp(mobile_number, otp_code)
      true
    else
      otp_verification.increment!(:attempts)
      if otp_verification.attempts >= MAX_ATTEMPTS
        otp_verification.update(is_used: true)
      end
      false
    end
  end

  def otp_valid?(mobile_number)
    otp = OtpVerification.find_by(
      mobile_number:,
      is_used: false
    )

    return false if otp.blank?
    return false if otp.expires_at < Time.current

    true
  end

  private

  def send_sms(mobile_number, otp_code)
    sms_service = SmsOtpService.new
    sms_service.send_otp_sms(mobile_number, otp_code)
  end
end
