# frozen_string_literal: true

# Category model - Transaction categories (predefined)
# Attributes:
#   - persian_name: Category name in Persian
#   - icon_code: Icon identifier for UI display
#   - display_order: Sort order for UI listing

class Category < ApplicationRecord
  # Associations
  has_many :transactions, dependent: :restrict_with_error

  # Validations
  validates :persian_name, presence: true, uniqueness: true
  validates :icon_code, presence: true, uniqueness: true
  validates :display_order, presence: true, numericality: { only_integer: true }

  # Scopes
  scope :ordered, -> { order(display_order: :asc) }

  # 7 Predefined categories
  # خوراک (Food)
  # حمل‌ونقل (Transport)
  # قبوض (Bills)
  # خرید (Shopping)
  # سلامت (Health)
  # تفریح (Entertainment)
  # سایر (Other)

  def self.seed_defaults
    [
      { persian_name: 'خوراک', icon_code: 'grocery', display_order: 1 },
      { persian_name: 'حمل‌ونقل', icon_code: 'transport', display_order: 2 },
      { persian_name: 'قبوض', icon_code: 'bills', display_order: 3 },
      { persian_name: 'خرید', icon_code: 'shopping', display_order: 4 },
      { persian_name: 'سلامت', icon_code: 'health', display_order: 5 },
      { persian_name: 'تفریح', icon_code: 'entertainment', display_order: 6 },
      { persian_name: 'سایر', icon_code: 'other', display_order: 7 }
    ]
  end

  def self.find_or_create_defaults
    seed_defaults.each do |attrs|
      find_or_create_by(icon_code: attrs[:icon_code]) do |category|
        category.persian_name = attrs[:persian_name]
        category.display_order = attrs[:display_order]
      end
    end
  end

  def self.other
    find_by(icon_code: 'other')
  end
end
