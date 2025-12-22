# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:mobile_number) { |n| format('090%08d', n) }
    password_digest { BCrypt::Password.create('TestPassword123') }
    # Let the DB/schema default apply (currently `otp_pending`).
    failed_login_attempts { 0 }
    locked_at { nil }
    locked_until { nil }
    last_login_at { nil }

    trait :with_balance do
      after(:create) do |user|
        user.user_balance || UserBalance.create!(user: user, total_toman: 0)
      end
    end

    trait :skip_balance do
      after(:build) do |user|
        user.skip_balance_initialization = true
      end
    end
  end
end
