# frozen_string_literal: true

class AddIsUsedToOtpVerifications < ActiveRecord::Migration[8.0]
  def change
    add_column :otp_verifications, :is_used, :boolean, null: false, default: false
    add_index :otp_verifications, :is_used
  end
end
