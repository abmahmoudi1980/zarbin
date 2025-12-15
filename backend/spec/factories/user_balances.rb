# frozen_string_literal: true

FactoryBot.define do
  factory :user_balance do
    user { association(:user, :skip_balance) }
    total_toman { 0 }
    total_usd_equivalent { 0.0 }
    total_gold_grams_equivalent { 0.0 }
  end
end
