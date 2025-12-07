# frozen_string_literal: true

class SmsOtpService
  KAVENEGAR_API_BASE = "https://api.kavenegar.com"
  KAVENEGAR_API_KEY = ENV["KAVENEGAR_API_KEY"]
  SMS_SENDER = ENV["SMS_SENDER_NAME"] || "Zarbin"
  OTP_EXPIRY_MINUTES = ENV["OTP_EXPIRY_MINUTES"]&.to_i || 10
  OTP_MAX_ATTEMPTS = ENV["OTP_MAX_ATTEMPTS"]&.to_i || 3

  class << self
    def generate_and_send_otp(mobile_number)
      # Validate mobile number format
      unless valid_mobile_number?(mobile_number)
        return { success: false, error: "Invalid mobile number format" }
      end

      # Generate OTP
      otp_verification = OtpVerification.generate_otp(mobile_number)
      
      # Send SMS
      send_result = send_sms(mobile_number, otp_verification.otp_code)
      
      unless send_result[:success]
        otp_verification.destroy
        return send_result
      end

      { success: true, message: "OTP sent successfully", expires_in_minutes: OTP_EXPIRY_MINUTES }
    rescue StandardError => e
      Rails.logger.error("OTP generation error: #{e.message}")
      { success: false, error: "Failed to generate OTP" }
    end

    def verify_otp(mobile_number, code)
      unless valid_mobile_number?(mobile_number)
        return { success: false, error: "Invalid mobile number format" }
      end

      otp_verification = OtpVerification.for_number(mobile_number).valid.last

      if otp_verification.blank?
        return { success: false, error: "No valid OTP found for this number" }
      end

      if otp_verification.verify(code)
        { success: true, message: "OTP verified successfully", otp_id: otp_verification.id }
      else
        { success: false, error: "Invalid OTP code or attempts exceeded" }
      end
    rescue StandardError => e
      Rails.logger.error("OTP verification error: #{e.message}")
      { success: false, error: "Failed to verify OTP" }
    end

    def resend_otp(mobile_number)
      unless valid_mobile_number?(mobile_number)
        return { success: false, error: "Invalid mobile number format" }
      end

      # Delete expired OTPs
      OtpVerification.for_number(mobile_number).expired.delete_all

      # Generate and send new OTP
      generate_and_send_otp(mobile_number)
    rescue StandardError => e
      Rails.logger.error("OTP resend error: #{e.message}")
      { success: false, error: "Failed to resend OTP" }
    end

    def cleanup_expired_otps
      OtpVerification.where("expires_at < ?", Time.current).delete_all
    end

    private

    def valid_mobile_number?(mobile_number)
      mobile_number.match?(/\A09\d{9}\z/)
    end

    def send_sms(mobile_number, otp_code)
      message = "کد تایید Zarbin: #{otp_code}"
      
      return { success: false, error: "Kavenegar API key not configured" } if KAVENEGAR_API_KEY.blank?

      send_result = send_sms_via_kavenegar(mobile_number, message)
      
      unless send_result[:success]
        Rails.logger.warn("SMS sending failed for #{mobile_number}: #{send_result[:error]}")
      end
      
      send_result
    rescue StandardError => e
      Rails.logger.error("SMS sending error: #{e.message}")
      { success: false, error: "Failed to send SMS" }
    end

    def send_sms_via_kavenegar(mobile_number, message)
      require "net/http"
      require "json"

      url = "#{KAVENEGAR_API_BASE}/v1/#{KAVENEGAR_API_KEY}/sms/send.json"
      
      params = {
        receptor: mobile_number,
        message: message,
        sender: SMS_SENDER
      }

      uri = URI(url)
      uri.query = URI.encode_www_form(params)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")

      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        result = JSON.parse(response.body)
        
        if result["result"] && result["result"]["status"] == 200
          { success: true, message: "SMS sent successfully" }
        else
          { success: false, error: result["result"]&.dig("message") || "Unknown error" }
        end
      else
        { success: false, error: "HTTP error: #{response.code}" }
      end
    rescue StandardError => e
      Rails.logger.error("Kavenegar API error: #{e.message}")
      { success: false, error: "SMS gateway error" }
    end
  end
end
