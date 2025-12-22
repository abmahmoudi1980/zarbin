# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    user { association :user, account_status: :active }
    # Use "other" category or find existing one to avoid creating extra categories
    category { Category.find_by(icon_code: 'other') || association(:category, :other) }

    amount_toman { 100_000 }
    transaction_type { 'expense' }
    transaction_date { '1403/01/15' }

    usd_rate_at_creation { 42_500.0 }
    gold_rate_at_creation { 2_150_000 }
    notes { nil }
  end
end
