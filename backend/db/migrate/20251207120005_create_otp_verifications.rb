# frozen_string_literal: true

class CreateOtpVerifications < ActiveRecord::Migration[8.0]
  def change
    create_table :otp_verifications do |t|
      t.string :mobile_number, null: false
      t.string :otp_code, null: false
      t.datetime :expires_at, null: false
      t.integer :attempts, default: 0, null: false
      t.boolean :verified, default: false, null: false

      t.timestamps
    end

    # Indexes
    add_index :otp_verifications, :mobile_number
    add_index :otp_verifications, :expires_at
    add_index :otp_verifications, :verified
  end
end
