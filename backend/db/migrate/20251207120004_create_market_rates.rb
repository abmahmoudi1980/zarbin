# frozen_string_literal: true

class CreateMarketRates < ActiveRecord::Migration[8.0]
  def change
    create_table :market_rates do |t|
      t.string :rate_type, null: false
      t.bigint :value_in_toman, null: false
      t.datetime :timestamp, null: false

      t.timestamps
    end

    # Indexes
    add_index :market_rates, :rate_type
    add_index :market_rates, :timestamp
    add_index :market_rates, [:rate_type, :timestamp], unique: false
  end
end
