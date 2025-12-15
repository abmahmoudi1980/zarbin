# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_12_15_104500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "persian_name", null: false
    t.string "icon_code", null: false
    t.integer "display_order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_order"], name: "index_categories_on_display_order"
    t.index ["icon_code"], name: "index_categories_on_icon_code", unique: true
    t.index ["persian_name"], name: "index_categories_on_persian_name", unique: true
  end

  create_table "market_rates", force: :cascade do |t|
    t.string "rate_type", null: false
    t.bigint "value_in_toman", null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rate_type", "timestamp"], name: "index_market_rates_on_rate_type_and_timestamp"
    t.index ["rate_type"], name: "index_market_rates_on_rate_type"
    t.index ["timestamp"], name: "index_market_rates_on_timestamp"
  end

  create_table "otp_verifications", force: :cascade do |t|
    t.string "mobile_number", null: false
    t.string "otp_code", null: false
    t.datetime "expires_at", null: false
    t.integer "attempts", default: 0, null: false
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_used", default: false, null: false
    t.index ["expires_at"], name: "index_otp_verifications_on_expires_at"
    t.index ["is_used"], name: "index_otp_verifications_on_is_used"
    t.index ["mobile_number"], name: "index_otp_verifications_on_mobile_number"
    t.index ["verified"], name: "index_otp_verifications_on_verified"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "amount_toman", null: false
    t.string "transaction_type", null: false
    t.bigint "category_id"
    t.string "transaction_date", null: false
    t.float "usd_rate_at_creation", null: false
    t.bigint "gold_rate_at_creation", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["created_at"], name: "index_transactions_on_created_at"
    t.index ["transaction_date"], name: "index_transactions_on_transaction_date"
    t.index ["transaction_type"], name: "index_transactions_on_transaction_type"
    t.index ["user_id", "transaction_date"], name: "index_transactions_on_user_id_and_transaction_date"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "user_balances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "total_toman", default: 0, null: false
    t.float "total_usd_equivalent", default: 0.0, null: false
    t.float "total_gold_grams_equivalent", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_balances_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "mobile_number", null: false
    t.string "password_digest", null: false
    t.string "account_status", default: "otp_pending", null: false
    t.integer "failed_login_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "locked_until"
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_status"], name: "index_users_on_account_status"
    t.index ["last_login_at"], name: "index_users_on_last_login_at"
    t.index ["locked_until"], name: "index_users_on_locked_until"
    t.index ["mobile_number"], name: "index_users_on_mobile_number", unique: true
  end

  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "users"
  add_foreign_key "user_balances", "users"
end
