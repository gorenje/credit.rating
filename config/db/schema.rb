# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170627130759) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "figo_account_id"
    t.string "owner"
    t.string "name"
    t.string "account_number"
    t.string "currency"
    t.string "iban"
    t.string "account_type"
    t.text "icon_url"
    t.decimal "last_known_balance"
    t.string "sepa_creditor_id"
    t.boolean "save_pin"
    t.text "credentials"
    t.integer "user_id"
    t.integer "bank_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "figo_account_id"], name: "index_accounts_on_user_id_and_figo_account_id"
  end

  create_table "banks", id: :serial, force: :cascade do |t|
    t.string "figo_bank_id"
    t.string "figo_bank_code"
    t.string "figo_bank_name"
    t.string "iban_bank_code"
    t.string "iban_bank_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["figo_bank_id"], name: "index_banks_on_figo_bank_id"
    t.index ["iban_bank_code"], name: "index_banks_on_iban_bank_code"
  end

  create_table "figo_supported_banks", id: :serial, force: :cascade do |t|
    t.string "bank_name"
    t.string "bank_code"
    t.text "advice"
    t.text "details_json"
    t.string "bic"
    t.index ["bank_code"], name: "index_figo_supported_banks_on_bank_code"
  end

  create_table "figo_supported_services", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "bank_code"
    t.text "advice"
    t.text "details_json"
    t.index ["bank_code"], name: "index_figo_supported_services_on_bank_code"
  end

  create_table "rating_histories", id: :serial, force: :cascade do |t|
    t.integer "score"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.hstore "details"
  end

  create_table "ratings", id: :serial, force: :cascade do |t|
    t.integer "score"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.hstore "details"
  end

  create_table "transactions", id: :serial, force: :cascade do |t|
    t.string "transaction_id"
    t.string "name"
    t.decimal "amount"
    t.string "currency"
    t.date "booking_date"
    t.date "value_date"
    t.boolean "booked"
    t.text "booking_text"
    t.text "purpose"
    t.text "transaction_type"
    t.hstore "extras"
    t.string "classname"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "transaction_id"], name: "index_transactions_on_account_id_and_transaction_id"
    t.index ["transaction_id"], name: "index_transactions_on_transaction_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.hstore "address"
    t.boolean "email_verified"
    t.string "language"
    t.datetime "join_date"
    t.text "credentials"
    t.string "salt"
    t.string "confirm_token"
    t.boolean "has_confirmed", default: false
    t.hstore "last_import_attempt_status"
    t.datetime "last_successful_import"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["last_successful_import"], name: "index_users_on_last_successful_import"
  end

end
