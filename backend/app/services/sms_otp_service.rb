# frozen_string_literal: true

class SmsOtpService
  class SendError < StandardError; end

  OTP_EXPIRY_MINUTES = ENV.fetch('OTP_EXPIRY_MINUTES', 10).to_i

  def send_otp(mobile_number)
    otp_verification = OtpVerification.generate_otp(mobile_number)
    otp_verification.update!(expires_at: OTP_EXPIRY_MINUTES.minutes.from_now)

    OtpVerification.where(mobile_number: mobile_number).where.not(id: otp_verification.id).update_all(is_used: true)

    sent = call_kavenegar_api(phone: mobile_number, otp: otp_verification.otp_code, template_name: 'zarbin_otp')
    raise SendError, 'Failed to send OTP' unless sent

    otp_verification
  end

  # Backwards-compatible sender used by older OtpService implementation.
  # Accepts an explicit OTP code and sends it via the configured provider.
  def send_otp_sms(mobile_number, otp_code)
    sent = call_kavenegar_api(phone: mobile_number, otp: otp_code, template_name: 'zarbin_otp')
    raise SendError, 'Failed to send OTP' unless sent

    true
  end

  def verify_otp(mobile_number, code)
    otp = OtpVerification.where(mobile_number: mobile_number, is_used: false).order(created_at: :desc).first
    return false if otp.blank?
    return false if otp.expires_at <= Time.current
    return false if otp.is_used

    if otp.otp_code.to_s == code.to_s
      otp.update!(is_used: true)
      true
    else
      false
    end
  end

  def generate_otp
    rand(100000..999999).to_s
  end

  def call_kavenegar_api(phone:, otp:, template_name:)
    return true if ENV['KAVENEGAR_API_KEY'].blank?

    require 'net/http'
    uri = URI('https://api.kavenegar.com')
    Net::HTTP.post_form(uri, { phone: phone, otp: otp, template_name: template_name })
    true
  rescue StandardError
    false
  end
end
