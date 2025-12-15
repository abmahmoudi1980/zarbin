# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:persian_name) { |n| "دسته‌بندی #{n}" }
    sequence(:icon_code) { |n| "icon_#{n}" }
    sequence(:display_order) { |n| n }

    trait :food do
      persian_name { 'خوراک' }
      icon_code { 'grocery' }
      display_order { 1 }
    end

    trait :other do
      persian_name { 'سایر' }
      icon_code { 'other' }
      display_order { 7 }
    end
  end
end
