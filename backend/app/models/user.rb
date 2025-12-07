# frozen_string_literal: true

# User model - Authentication and account management
# Attributes:
#   - mobile_number: Iranian mobile number (unique, required, encrypted)
#   - password_digest: bcrypt hashed password
#   - account_status: enum (active, suspended, deleted)
#   - failed_login_attempts: counter for lockout
#   - locked_until: timestamp for account lockout period
#   - last_login_at: last successful login timestamp

class User < ApplicationRecord
  # Encrypt sensitive data at rest
  encrypts :mobile_number, deterministic: true

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
    in: %w(active otp_pending suspended deleted locked),
    message: '%{value} is not a valid account status' 
  }
  validates :failed_login_attempts, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Enums
  enum account_status: { active: 'active', otp_pending: 'otp_pending', suspended: 'suspended', deleted: 'deleted', locked: 'locked' }

  # Scopes
  scope :active_only, -> { where(account_status: :active) }
  scope :recently_locked, -> { where('locked_until > ?', Time.current) }

  # Password handling with bcrypt
  has_secure_password

  # Callbacks
  after_create :initialize_balance

  # Instance Methods

  def authenticate(password)
    return false if account_locked? || locked_account?
    
    unless password_digest.blank? && BCrypt::Password.new(password_digest).is_password?(password)
      increment_failed_attempts
      return false
    end

    reset_failed_attempts
    update(last_login_at: Time.current)
    true
  end

  def account_locked?
    account_status == 'locked' && locked_at.present? && locked_at > 15.minutes.ago
  end

  def locked_account?
    locked_until.present? && locked_until > Time.current
  end

  def can_attempt_login?
    if account_locked? && locked_at.present? && locked_at <= 15.minutes.ago
      reset_failed_attempts
      update(account_status: :active)
      return true
    end

    !account_locked?
  end

  def locked_out_until
    return nil unless locked_at

    locked_at + 15.minutes
  end

  def increment_failed_attempts
    new_attempts = (failed_login_attempts || 0) + 1
    if new_attempts >= 5
      update(
        failed_login_attempts: new_attempts,
        account_status: :locked,
        locked_at: Time.current
      )
    else
      update(failed_login_attempts: new_attempts)
    end
  end

  def reset_failed_attempts
    update(failed_login_attempts: 0, locked_at: nil, account_status: :active)
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
