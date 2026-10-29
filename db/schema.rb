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

ActiveRecord::Schema[8.1].define(version: 2026_10_29_014316) do
  create_table "calendar_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "firm_id", null: false
    t.bigint "user_id", null: false
    t.bigint "matter_id"
    t.string "title", null: false
    t.string "location"
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["firm_id"], name: "index_calendar_events_on_firm_id"
    t.index ["matter_id"], name: "index_calendar_events_on_matter_id"
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
  end

  create_table "contacts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "firm_id", null: false
    t.string "name", null: false
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["firm_id", "name"], name: "index_contacts_on_firm_id_and_name"
    t.index ["firm_id"], name: "index_contacts_on_firm_id"
  end

  create_table "firms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "time_zone", default: "Pacific Time (US & Canada)", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "firm_id", null: false
    t.bigint "client_id", null: false
    t.string "number", null: false
    t.string "title", null: false
    t.string "practice_area"
    t.string "status", default: "open", null: false
    t.date "opened_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_matters_on_client_id"
    t.index ["firm_id", "number"], name: "index_matters_on_firm_id_and_number", unique: true
    t.index ["firm_id"], name: "index_matters_on_firm_id"
  end

  create_table "sessions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tasks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "firm_id", null: false
    t.bigint "matter_id", null: false
    t.bigint "assignee_id", null: false
    t.string "title", null: false
    t.text "description"
    t.datetime "due_at"
    t.string "status", default: "open", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tasks_on_assignee_id"
    t.index ["firm_id"], name: "index_tasks_on_firm_id"
    t.index ["matter_id"], name: "index_tasks_on_matter_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "firm_id", null: false
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["firm_id"], name: "index_users_on_firm_id"
  end

  add_foreign_key "calendar_events", "firms"
  add_foreign_key "calendar_events", "matters"
  add_foreign_key "calendar_events", "users"
  add_foreign_key "contacts", "firms"
  add_foreign_key "matters", "contacts", column: "client_id"
  add_foreign_key "matters", "firms"
  add_foreign_key "sessions", "users"
  add_foreign_key "tasks", "firms"
  add_foreign_key "tasks", "matters"
  add_foreign_key "tasks", "users", column: "assignee_id"
  add_foreign_key "users", "firms"
end
