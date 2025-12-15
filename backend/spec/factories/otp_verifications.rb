# frozen_string_literal: true

FactoryBot.define do
  factory :otp_verification do
    sequence(:mobile_number) { |n| format('09%09d', 100_000_000 + n) }
    otp_code { '123456' }
    expires_at { 10.minutes.from_now }
    attempts { 0 }
    verified { false }
  end
end
