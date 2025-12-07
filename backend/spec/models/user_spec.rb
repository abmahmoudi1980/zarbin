require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:mobile_number) }
    it { is_expected.to validate_presence_of(:password_hash) }
    
    it 'validates uniqueness of mobile_number' do
      create(:user, mobile_number: '09123456789')
      user = build(:user, mobile_number: '09123456789')
      
      expect(user).not_to be_valid
      expect(user.errors[:mobile_number]).to include('has already been taken')
    end
  end

  describe '#authenticate' do
    let(:user) { create(:user, password: 'Password123') }

    context 'with correct password' do
      it 'returns true' do
        expect(user.authenticate('Password123')).to be true
      end
    end

    context 'with incorrect password' do
      it 'returns false' do
        expect(user.authenticate('WrongPassword')).to be false
      end
    end

    context 'with nil password' do
      it 'returns false' do
        expect(user.authenticate(nil)).to be false
      end
    end
  end

  describe '#password=' do
    it 'hashes the password using bcrypt' do
      user = create(:user, password: 'Password123')
      
      expect(user.password_hash).not_to eq('Password123')
      expect(user.password_hash).to be_present
    end

    it 'stores bcrypt-compatible hash' do
      user = User.new(mobile_number: '09123456789')
      user.password = 'TestPassword123'
      
      hash = user.password_hash
      expect(BCrypt::Password.new(hash)).to eq('TestPassword123')
    end
  end

  describe 'account_status' do
    it 'defaults to otp_pending' do
      user = create(:user)
      expect(user.account_status).to eq('otp_pending')
    end

    it 'can be set to active' do
      user = create(:user, account_status: :active)
      expect(user.account_status).to eq('active')
    end

    it 'can be set to locked' do
      user = create(:user, account_status: :locked)
      expect(user.account_status).to eq('locked')
    end
  end

  describe '#account_locked?' do
    it 'returns true when account_status is locked' do
      user = create(:user, account_status: :locked)
      expect(user.account_locked?).to be true
    end

    it 'returns false when account_status is not locked' do
      user = create(:user, account_status: :active)
      expect(user.account_locked?).to be false
    end
  end

  describe 'failed login attempts' do
    let(:user) { create(:user) }

    describe '#increment_failed_attempts' do
      it 'increments failed_login_attempts counter' do
        expect {
          user.increment_failed_attempts
        }.to change { user.reload.failed_login_attempts }.by(1)
      end

      it 'locks account after 5 failed attempts' do
        5.times { user.increment_failed_attempts }
        
        user.reload
        expect(user.failed_login_attempts).to eq(5)
        expect(user.account_status).to eq('locked')
      end
    end

    describe '#reset_failed_attempts' do
      it 'resets failed_login_attempts to 0' do
        user.update(failed_login_attempts: 3)
        
        user.reset_failed_attempts
        
        expect(user.failed_login_attempts).to eq(0)
      end

      it 'unlocks account if locked' do
        user.update(account_status: :locked, failed_login_attempts: 5)
        
        user.reset_failed_attempts
        
        expect(user.account_status).to eq('active')
      end
    end

    describe '#locked_out_until' do
      it 'calculates unlock time as 15 minutes after lock' do
        user.update(account_status: :locked, locked_at: 10.minutes.ago)
        
        unlock_time = user.locked_out_until
        
        expect(unlock_time).to be_between(4.minutes.ago, 6.minutes.ago)
      end
    end

    describe '#can_attempt_login?' do
      it 'returns true when not locked' do
        user.update(account_status: :active)
        expect(user.can_attempt_login?).to be true
      end

      it 'returns false when locked and within 15 minutes' do
        user.update(account_status: :locked, locked_at: 10.minutes.ago)
        expect(user.can_attempt_login?).to be false
      end

      it 'returns true when locked but 15+ minutes have passed' do
        user.update(account_status: :locked, locked_at: 16.minutes.ago)
        expect(user.can_attempt_login?).to be true
      end

      it 'auto-unlocks when time expired' do
        user.update(account_status: :locked, locked_at: 16.minutes.ago, failed_login_attempts: 5)
        
        user.can_attempt_login?
        user.reload
        
        expect(user.account_status).to eq('active')
        expect(user.failed_login_attempts).to eq(0)
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:transactions) }
    it { is_expected.to have_one(:user_balance) }
    it { is_expected.to have_many(:otp_verifications) }
  end
end
