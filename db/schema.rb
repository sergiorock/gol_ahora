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

ActiveRecord::Schema[8.1].define(version: 2026_05_09_024153) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "asistencias", force: :cascade do |t|
    t.bigint "asistible_id", null: false
    t.string "asistible_type", null: false
    t.date "attended_on"
    t.datetime "created_at", null: false
    t.boolean "present", default: false, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["asistible_type", "asistible_id"], name: "index_asistencias_on_asistible"
    t.index ["user_id"], name: "index_asistencias_on_user_id"
  end

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

  create_table "clases", force: :cascade do |t|
    t.bigint "court_type_id"
    t.datetime "created_at", null: false
    t.text "descripcion"
    t.integer "duration_minutes", null: false
    t.integer "max_students", null: false
    t.string "nombre", null: false
    t.bigint "personal_deportivo_id", null: false
    t.datetime "scheduled_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["court_type_id"], name: "index_clases_on_court_type_id"
    t.index ["personal_deportivo_id"], name: "index_clases_on_personal_deportivo_id"
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

  create_table "enrollments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "enrollable_id", null: false
    t.string "enrollable_type", null: false
    t.datetime "enrolled_at", null: false
    t.integer "status", default: 0, null: false
    t.string "team_name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["enrollable_type", "enrollable_id"], name: "index_enrollments_on_enrollable_type_and_enrollable_id"
    t.index ["user_id", "enrollable_type", "enrollable_id"], name: "index_one_enrollment_per_user_per_competition", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "entrenamientos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "descripcion"
    t.integer "duration_minutes", null: false
    t.integer "max_students", null: false
    t.string "nombre", null: false
    t.bigint "personal_deportivo_id", null: false
    t.datetime "scheduled_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["personal_deportivo_id"], name: "index_entrenamientos_on_personal_deportivo_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.string "name", null: false
    t.text "rules"
    t.date "start_date"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  create_table "matches", force: :cascade do |t|
    t.integer "away_goals"
    t.string "away_team"
    t.bigint "competition_id"
    t.string "competition_type"
    t.bigint "court_id"
    t.datetime "created_at", null: false
    t.integer "home_goals"
    t.string "home_team"
    t.text "official_rules"
    t.datetime "played_at"
    t.datetime "updated_at", null: false
    t.index ["competition_type", "competition_id"], name: "index_matches_on_competition_type_and_competition_id"
    t.index ["court_id"], name: "index_matches_on_court_id"
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

  create_table "personal_deportivos", force: :cascade do |t|
    t.string "apellido"
    t.string "certificacion_deportiva"
    t.datetime "created_at", null: false
    t.string "email"
    t.date "fecha_certificacion"
    t.string "nombre"
    t.text "observaciones"
    t.string "telefono"
    t.integer "tipo"
    t.datetime "updated_at", null: false
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

  create_table "tournaments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.integer "format", default: 0, null: false
    t.string "name", null: false
    t.text "rules"
    t.date "start_date"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "asistencias", "users"
  add_foreign_key "charges", "discounts"
  add_foreign_key "charges", "reservations"
  add_foreign_key "charges", "users"
  add_foreign_key "clases", "court_types"
  add_foreign_key "clases", "personal_deportivos"
  add_foreign_key "court_blocks", "courts"
  add_foreign_key "courts", "court_types"
  add_foreign_key "enrollments", "users"
  add_foreign_key "entrenamientos", "personal_deportivos"
  add_foreign_key "matches", "courts"
  add_foreign_key "payments", "reservations"
  add_foreign_key "receipts", "charges"
  add_foreign_key "reservations", "courts"
  add_foreign_key "reservations", "users"
end
