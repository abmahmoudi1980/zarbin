# frozen_string_literal: true

class CreateUserBalances < ActiveRecord::Migration[8.0]
  def change
    create_table :user_balances do |t|
      t.references :user, null: false, foreign_key: true
      t.bigint :total_toman, default: 0, null: false
      t.float :total_usd_equivalent, default: 0.0, null: false
      t.float :total_gold_grams_equivalent, default: 0.0, null: false

      t.timestamps
    end
  end
end
