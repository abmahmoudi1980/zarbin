# frozen_string_literal: true

module Api
  module V1
    class TransactionsController < Api::V1::ApplicationController
      # JWT verification inherited from Api::V1::ApplicationController
      before_action :set_user, only: [:create, :index, :show, :destroy, :monthly_summary]
      before_action :set_transaction, only: [:show, :destroy, :update]

      # GET /api/v1/transactions
      def index
        # Add pagination support
        page = params[:page].to_i
        per_page = params[:per_page].to_i
        page = 1 if page < 1
        per_page = 10 if per_page < 1 || per_page > 100
        
        transactions = @user.transactions.ordered
        total = transactions.count
        transactions = transactions.offset((page - 1) * per_page).limit(per_page)
        
        render json: {
          success: true,
          data: transactions.map { |t| format_transaction(t) },
          pagination: {
            current_page: page,
            per_page: per_page,
            total_count: total,
            total_pages: (total.to_f / per_page).ceil
          }
        }
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # GET /api/v1/transactions/:id
      def show
        unless @transaction
          return render json: { error: "Transaction not found" }, status: :not_found
        end
        
        unless @transaction.user_id == current_user.id
          return render json: { error: "Forbidden" }, status: :forbidden
        end
        
        render json: {
          success: true,
          data: format_transaction(@transaction)
        }
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # POST /api/v1/transactions
      def create
        # Validate required params before building
        unless transaction_params[:amount_toman].present? && 
               transaction_params[:transaction_type].present? && 
               transaction_params[:transaction_date].present?
          missing = []
          missing << 'amount_toman' unless transaction_params[:amount_toman].present?
          missing << 'transaction_type' unless transaction_params[:transaction_type].present?
          missing << 'transaction_date' unless transaction_params[:transaction_date].present?
          return render json: { 
            success: false, 
            error: "Missing required fields: #{missing.join(', ')}" 
          }, status: :unprocessable_entity
        end
        
        transaction = @user.transactions.build(transaction_params)
        
        # Capture exchange rates at creation time for historical accuracy (T085)
        # Use safe fetching that doesn't raise exceptions
        begin
          transaction.usd_rate_at_creation ||= CurrencyService.get_current_rate('USD') || 42_500
        rescue StandardError
          transaction.usd_rate_at_creation = 42_500
        end
        
        begin
          transaction.gold_rate_at_creation ||= CurrencyService.get_current_rate('Gold') || 2_150_000
        rescue StandardError
          transaction.gold_rate_at_creation = 2_150_000
        end
        
        if transaction.save
          Rails.logger.info("Transaction created: #{transaction.id} for user #{@user.id}, amount: #{transaction.amount_toman} #{transaction.transaction_type}")
          render json: format_transaction_with_success(transaction), status: :created
        else
          Rails.logger.warn("Transaction creation failed for user #{@user.id}: #{transaction.errors.full_messages.join(', ')}")
          render json: { 
            success: false, 
            error: transaction.errors.full_messages.join(', ')
          }, status: :unprocessable_entity
        end
      rescue ArgumentError => e
        # Handle invalid enum values like invalid transaction_type
        render json: { 
          success: false, 
          error: e.message 
        }, status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error("Error creating transaction for user #{@user.id}: #{e.class} - #{e.message}")
        render json: { error: e.message }, status: :internal_server_error
      end

      # PATCH/PUT /api/v1/transactions/:id
      def update
        if @transaction.user_id == current_user.id
          old_amount = @transaction.amount_toman
          if @transaction.update(transaction_params)
            Rails.logger.info("Transaction updated: #{@transaction.id}, amount changed from #{old_amount} to #{@transaction.amount_toman}")
            render json: {
              success: true,
              data: format_transaction(@transaction)
            }
          else
            Rails.logger.warn("Transaction update failed: #{@transaction.id}: #{@transaction.errors.full_messages.join(', ')}")
            render json: { errors: @transaction.errors.full_messages }, status: :unprocessable_entity
          end
        else
          Rails.logger.warn("Unauthorized transaction update attempt: user #{current_user.id} tried to update transaction #{@transaction.id}")
          render json: { error: "Unauthorized" }, status: :forbidden
        end
      rescue StandardError => e
        Rails.logger.error("Error updating transaction #{@transaction.id}: #{e.class} - #{e.message}")
        render json: { error: e.message }, status: :internal_server_error
      end

      # DELETE /api/v1/transactions/:id
      def destroy
        unless @transaction
          return render json: { error: "Transaction not found" }, status: :not_found
        end
        
        unless @transaction.user_id == current_user.id
          Rails.logger.warn("Unauthorized transaction delete attempt: user #{current_user.id} tried to delete transaction #{@transaction.id}")
          return render json: { error: "Unauthorized" }, status: :forbidden
        end
        
        transaction_id = @transaction.id
        amount = @transaction.amount_toman
        
        if @transaction.destroy
          Rails.logger.info("Transaction deleted: #{transaction_id}, amount: #{amount}")
          head :no_content
        else
          render json: { 
            success: false,
            error: "Failed to delete transaction" 
          }, status: :unprocessable_entity
        end
      rescue StandardError => e
        Rails.logger.error("Error deleting transaction #{@transaction&.id}: #{e.class} - #{e.message}")
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
        @transaction = Transaction.find_by(id: params[:id])
      end

      def transaction_params
        # Accept both nested and non-nested params for flexibility
        source = params[:transaction] || params
        source.permit(:amount_toman, :transaction_type, :category_id, :transaction_date, :notes).tap do |p|
          # Sanitize notes to prevent XSS
          p[:notes] = sanitize_text(p[:notes]) if p[:notes].present?
        end
      end

      def sanitize_text(text)
        # Remove potentially malicious content while preserving Persian text
        # Allow only safe Unicode characters, spaces, and basic punctuation
        text.to_s.gsub(/[^\p{L}\p{N}\s\.,\-!?،؛]/u, '').strip[0...500]
      end

      def format_transaction(transaction)
        {
          id: transaction.id,
          user_id: transaction.user_id,
          amount_toman: transaction.amount_toman,
          transaction_type: transaction.transaction_type,
          category: {
            id: transaction.category&.id,
            persian_name: transaction.category&.persian_name,
            icon_code: transaction.category&.icon_code
          },
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
