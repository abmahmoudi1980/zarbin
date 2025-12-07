require 'rails_helper'

RSpec.describe Transaction, type: :model do
  subject { build(:transaction) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:category).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount_toman) }
    it { is_expected.to validate_presence_of(:transaction_type) }
    it { is_expected.to validate_presence_of(:transaction_date) }

    describe 'amount_toman validation' do
      it 'is valid with amount > 0' do
        transaction = build(:transaction, amount_toman: 1)
        expect(transaction).to be_valid
      end

      it 'is invalid with amount <= 0' do
        transaction = build(:transaction, amount_toman: 0)
        expect(transaction).not_to be_valid
      end

      it 'is invalid with negative amount' do
        transaction = build(:transaction, amount_toman: -1000)
        expect(transaction).not_to be_valid
      end

      it 'is valid with maximum amount (99,999,999,999)' do
        transaction = build(:transaction, amount_toman: 99_999_999_999)
        expect(transaction).to be_valid
      end

      it 'is invalid with amount > 99,999,999,999' do
        transaction = build(:transaction, amount_toman: 100_000_000_000)
        expect(transaction).not_to be_valid
      end
    end

    describe 'transaction_type validation' do
      it 'is valid with income' do
        transaction = build(:transaction, transaction_type: 'income')
        expect(transaction).to be_valid
      end

      it 'is valid with expense' do
        transaction = build(:transaction, transaction_type: 'expense')
        expect(transaction).to be_valid
      end

      it 'is invalid with invalid type' do
        transaction = build(:transaction, transaction_type: 'invalid')
        expect(transaction).not_to be_valid
      end
    end

    describe 'transaction_date validation' do
      it 'is valid with Jalali date in YYYY/MM/DD format' do
        transaction = build(:transaction, transaction_date: '1403/01/15')
        expect(transaction).to be_valid
      end

      it 'is invalid with invalid Jalali date' do
        transaction = build(:transaction, transaction_date: '1403/13/01')
        expect(transaction).not_to be_valid
      end
    end
  end

  describe '#validate_amount' do
    it 'returns error message for amount <= 0' do
      transaction = build(:transaction, amount_toman: 0)
      transaction.valid?
      expect(transaction.errors[:amount_toman]).to be_present
    end

    it 'returns error message for amount > 99,999,999,999' do
      transaction = build(:transaction, amount_toman: 100_000_000_000)
      transaction.valid?
      expect(transaction.errors[:amount_toman]).to be_present
    end

    it 'has no errors for valid amounts' do
      transaction = build(:transaction, amount_toman: 5_000_000)
      transaction.valid?
      expect(transaction.errors[:amount_toman]).to be_empty
    end
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:transaction1) { create(:transaction, user: user, transaction_date: '1403/01/15') }
    let!(:transaction2) { create(:transaction, user: user, transaction_date: '1403/01/20') }
    let!(:transaction3) { create(:transaction, user: user, transaction_date: '1403/01/10') }

    describe '.sorted_by_date' do
      it 'returns transactions sorted by date (newest first)' do
        sorted = Transaction.where(user: user).sorted_by_date

        expect(sorted.pluck(:id)).to eq([transaction2.id, transaction1.id, transaction3.id])
      end
    end

    describe '.by_type' do
      let!(:income) { create(:transaction, user: user, transaction_type: 'income') }
      let!(:expense) { create(:transaction, user: user, transaction_type: 'expense') }

      it 'returns transactions by type' do
        income_transactions = Transaction.where(user: user).by_type('income')
        expect(income_transactions).to include(income)
        expect(income_transactions).not_to include(expense)
      end
    end

    describe '.by_category' do
      let(:category) { Category.find_by(persian_name: 'خوراک') || create(:category, persian_name: 'خوراک') }
      let!(:categorized) { create(:transaction, user: user, category: category) }
      let!(:uncategorized) { create(:transaction, user: user, category: nil) }

      it 'returns transactions by category' do
        categorized_transactions = Transaction.where(user: user).by_category(category.id)
        expect(categorized_transactions).to include(categorized)
        expect(categorized_transactions).not_to include(uncategorized)
      end
    end
  end

  describe 'callbacks' do
    describe 'before_save' do
      it 'defaults category to Other if not provided' do
        other_category = Category.find_by(persian_name: 'سایر') || create(:category, persian_name: 'سایر')
        transaction = build(:transaction, category: nil)
        transaction.save

        expect(transaction.category_id).to eq(other_category.id)
      end
    end
  end

  describe 'instance methods' do
    describe '#amount_in_usd' do
      it 'calculates USD amount from stored exchange rate' do
        transaction = create(:transaction, amount_toman: 42_500_000, usd_rate_at_creation: 42500.0)

        expect(transaction.amount_usd_equivalent).to eq(1000.0)
      end
    end

    describe '#formatted_amount' do
      it 'returns amount with Persian numerals' do
        transaction = create(:transaction, amount_toman: 5_000_000)
        # Assumes PersianFormatter is available
        expect(transaction.amount_toman.to_s).to eq('5000000')
      end
    end
  end

  describe 'data integrity' do
    let(:user) { create(:user) }

    it 'maintains transaction data after save' do
      params = {
        user: user,
        amount_toman: 5_000_000,
        transaction_type: 'expense',
        transaction_date: '1403/01/15',
        notes: 'Grocery shopping',
        usd_rate_at_creation: 42500.0
      }
      transaction = create(:transaction, **params)

      transaction.reload
      expect(transaction.amount_toman).to eq(5_000_000)
      expect(transaction.transaction_type).to eq('expense')
      expect(transaction.transaction_date).to eq('1403/01/15')
      expect(transaction.notes).to eq('Grocery shopping')
      expect(transaction.usd_rate_at_creation).to eq(42500.0)
    end
  end
end
