# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :mobile_number, null: false
      t.string :password_digest, null: false
      t.string :account_status, default: 'active', null: false
      t.integer :failed_login_attempts, default: 0, null: false
      t.datetime :locked_until
      t.datetime :last_login_at

      t.timestamps
    end

    # Indexes
    add_index :users, :mobile_number, unique: true
    add_index :users, :account_status
    add_index :users, :locked_until
    add_index :users, :last_login_at
  end
end
