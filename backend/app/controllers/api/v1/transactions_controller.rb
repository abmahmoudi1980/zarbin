# frozen_string_literal: true

module Api
  module V1
    class TransactionsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_request!, except: [:options]
      before_action :set_user, only: [:create, :index, :show, :destroy, :monthly_summary]
      before_action :set_transaction, only: [:show, :destroy, :update]

      # GET /api/v1/transactions
      def index
        transactions = @user.transactions.ordered
        render json: format_transactions(transactions)
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # GET /api/v1/transactions/:id
      def show
        render json: format_transaction(@transaction)
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # POST /api/v1/transactions
      def create
        transaction = @user.transactions.build(transaction_params)
        
        # Capture exchange rates at creation time for historical accuracy (T085)
        transaction.usd_rate_at_creation ||= CurrencyService.record_transaction_rate('USD')
        transaction.gold_rate_at_creation ||= CurrencyService.record_transaction_rate('Gold')
        
        if transaction.save
          render json: format_transaction_with_success(transaction), status: :created
        else
          render json: { 
            success: false, 
            error: transaction.errors.full_messages.join(', ')
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # PATCH/PUT /api/v1/transactions/:id
      def update
        if @transaction.user_id == current_user.id
          if @transaction.update(transaction_params)
            render json: format_transaction(@transaction)
          else
            render json: { errors: @transaction.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: "Unauthorized" }, status: :forbidden
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # DELETE /api/v1/transactions/:id
      def destroy
        if @transaction.user_id == current_user.id
          @transaction.destroy
          render json: { message: "Transaction deleted successfully" }, status: :ok
        else
          render json: { error: "Unauthorized" }, status: :forbidden
        end
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # GET /api/v1/transactions/summary/monthly
      def monthly_summary
        year = params[:year].to_i
        month = params[:month].to_i
        
        transactions = @user.transactions.for_jalali_month(year, month)
        
        total_income = transactions.income_only.sum(:amount_toman)
        total_expense = transactions.expense_only.sum(:amount_toman)
        net_balance = total_income - total_expense
        
        render json: {
          year: year,
          month: month,
          total_income: total_income,
          total_expense: total_expense,
          net_balance: net_balance,
          transaction_count: transactions.count
        }
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      private

      def set_user
        @user = current_user
      end

      def set_transaction
        @transaction = Transaction.find(params[:id])
      end

      def transaction_params
        params.require(:transaction).permit(:amount_toman, :transaction_type, :category_id, :transaction_date, :notes)
      end

      def format_transaction(transaction)
        {
          id: transaction.id,
          amount_toman: transaction.amount_toman,
          transaction_type: transaction.transaction_type,
          category: {
            id: transaction.category&.id,
            persian_name: transaction.category&.persian_name,
            icon_code: transaction.category&.icon_code
          },
          transaction_date: transaction.transaction_date,
          amount_usd_equivalent: transaction.amount_usd_equivalent,
          amount_gold_grams_equivalent: transaction.amount_gold_grams_equivalent,
          notes: transaction.notes,
          created_at: transaction.created_at,
          updated_at: transaction.updated_at
        }
      end

      def format_transaction_with_success(transaction)
        {
          success: true,
          data: {
            id: transaction.id,
            user_id: transaction.user_id,
            amount_toman: transaction.amount_toman,
            transaction_type: transaction.transaction_type,
            category_id: transaction.category_id,
            category_name: transaction.category&.persian_name || 'سایر',
            transaction_date: transaction.transaction_date,
            usd_rate_at_creation: transaction.usd_rate_at_creation,
            amount_usd_equivalent: transaction.amount_usd_equivalent,
            gold_rate_at_creation: transaction.gold_rate_at_creation,
            amount_gold_grams_equivalent: transaction.amount_gold_grams_equivalent,
            notes: transaction.notes,
            created_at: transaction.created_at,
            updated_at: transaction.updated_at
          }
        }
      end

      def format_transactions(transactions)
        {
          transactions: transactions.map { |t| format_transaction(t) },
          total: transactions.count,
          total_amount_toman: transactions.sum(:amount_toman)
        }
      end
    end
  end
end
