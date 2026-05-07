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

ActiveRecord::Schema[8.1].define(version: 2026_05_07_222810) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "charges", force: :cascade do |t|
    t.decimal "amount", null: false
    t.integer "charge_type", null: false
    t.string "concept", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.bigint "discount_id"
    t.boolean "is_deposit", default: false, null: false
    t.text "notes"
    t.integer "payment_method", default: 0, null: false
    t.bigint "reservation_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["discount_id"], name: "index_charges_on_discount_id"
    t.index ["reservation_id", "is_deposit"], name: "index_charges_one_balance_per_reservation", unique: true, where: "((reservation_id IS NOT NULL) AND (is_deposit = false))"
    t.index ["reservation_id"], name: "index_charges_on_reservation_id"
    t.index ["user_id"], name: "index_charges_on_user_id"
  end

  create_table "court_blocks", force: :cascade do |t|
    t.bigint "court_id", null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.string "reason"
    t.datetime "starts_at"
    t.datetime "updated_at", null: false
    t.index ["court_id"], name: "index_court_blocks_on_court_id"
  end

  create_table "court_types", force: :cascade do |t|
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.integer "max_duration_minutes"
    t.string "name"
    t.decimal "price_per_hour"
    t.string "surface"
    t.datetime "updated_at", null: false
  end

  create_table "courts", force: :cascade do |t|
    t.bigint "court_type_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["court_type_id"], name: "index_courts_on_court_type_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "condition"
    t.datetime "created_at", null: false
    t.integer "discount_type", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount"
    t.string "cardholder_name"
    t.datetime "created_at", null: false
    t.string "expiry_date"
    t.string "last_four_digits"
    t.integer "payment_type"
    t.bigint "reservation_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["reservation_id"], name: "index_payments_on_reservation_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.bigint "charge_id", null: false
    t.string "concept"
    t.datetime "created_at", null: false
    t.datetime "issued_at"
    t.string "receipt_number"
    t.datetime "updated_at", null: false
    t.index ["charge_id"], name: "index_receipts_on_charge_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "court_id", null: false
    t.datetime "created_at", null: false
    t.decimal "deposit_amount"
    t.datetime "ends_at"
    t.text "notes"
    t.datetime "starts_at"
    t.string "status"
    t.decimal "total_amount"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["court_id", "starts_at", "ends_at"], name: "index_reservations_on_court_id_and_starts_at_and_ends_at"
    t.index ["court_id"], name: "index_reservations_on_court_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.date "birth_date"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "dni"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", default: "", null: false
    t.datetime "joined_at"
    t.string "last_name", default: "", null: false
    t.string "phone"
    t.string "postal_code"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "charges", "discounts"
  add_foreign_key "charges", "reservations"
  add_foreign_key "charges", "users"
  add_foreign_key "court_blocks", "courts"
  add_foreign_key "courts", "court_types"
  add_foreign_key "payments", "reservations"
  add_foreign_key "receipts", "charges"
  add_foreign_key "reservations", "courts"
  add_foreign_key "reservations", "users"
end
