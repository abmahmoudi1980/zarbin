# frozen_string_literal: true

# User model - Authentication and account management
# Attributes:
#   - mobile_number: Iranian mobile number (unique, required)
#   - password_digest: bcrypt hashed password
#   - account_status: enum (active, suspended, deleted)
#   - failed_login_attempts: counter for lockout
#   - locked_until: timestamp for account lockout period
#   - last_login_at: last successful login timestamp

class User < ApplicationRecord
  # Associations
  has_many :transactions, dependent: :destroy
  has_many :otp_verifications, dependent: :destroy
  has_one :user_balance, dependent: :destroy
  has_many :authentication_logs, dependent: :destroy

  # Validations
  validates :mobile_number, presence: true, uniqueness: true, format: { 
    with: /\A09\d{9}\z/, 
    message: 'must be a valid Iranian mobile number (09XX XXX XXXX)' 
  }
  validates :password_digest, presence: true
  validates :account_status, presence: true, inclusion: { 
    in: %w(active suspended deleted),
    message: '%{value} is not a valid account status' 
  }
  validates :failed_login_attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Enums
  enum account_status: { active: 'active', suspended: 'suspended', deleted: 'deleted' }

  # Scopes
  scope :active_only, -> { where(account_status: :active) }
  scope :recently_locked, -> { where('locked_until > ?', Time.current) }

  # Password handling with bcrypt
  has_secure_password

  # Callbacks
  after_create :initialize_balance

  # Instance Methods

  def authenticate(password)
    return false if account_locked?
    
    if password_digest.blank? || !BCrypt::Password.new(password_digest).is_password?(password)
      increment_failed_login!
      return false
    end

    reset_failed_login!
    update(last_login_at: Time.current)
    true
  end

  def account_locked?
    locked_until.present? && locked_until > Time.current
  end

  def increment_failed_login!
    new_attempts = failed_login_attempts + 1
    if new_attempts >= 5
      # Lock account for 15 minutes
      update(
        failed_login_attempts: new_attempts,
        locked_until: 15.minutes.from_now
      )
    else
      update(failed_login_attempts: new_attempts)
    end
  end

  def reset_failed_login!
    update(failed_login_attempts: 0, locked_until: nil)
  end

  def activate!
    update(account_status: :active)
  end

  def suspend!
    update(account_status: :suspended)
  end

  def delete_account!
    update(account_status: :deleted)
  end

  private

  def initialize_balance
    UserBalance.create(user: self, total_toman: 0)
  end
end
