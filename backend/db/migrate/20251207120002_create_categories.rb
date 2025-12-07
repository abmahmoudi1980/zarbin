# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :persian_name, null: false
      t.string :icon_code, null: false
      t.integer :display_order, null: false

      t.timestamps
    end

    # Indexes
    add_index :categories, :persian_name, unique: true
    add_index :categories, :icon_code, unique: true
    add_index :categories, :display_order
  end
end
