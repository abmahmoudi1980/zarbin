# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :amount_toman, null: false
      t.string :transaction_type, null: false
      t.references :category, foreign_key: true
      t.string :transaction_date, null: false
      t.float :usd_rate_at_creation, null: false
      t.bigint :gold_rate_at_creation, null: false
      t.text :notes

      t.timestamps
    end

    # Indexes
    add_index :transactions, :user_id
    add_index :transactions, :transaction_type
    add_index :transactions, :transaction_date
    add_index :transactions, [:user_id, :transaction_date]
    add_index :transactions, :created_at
  end
end
