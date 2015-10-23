# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151013120343) do

  create_table "accounts", force: true do |t|
    t.string   "name"
    t.datetime "synchronized_at"
  end

  create_table "accounts_contacts", force: true do |t|
    t.integer "account_id"
    t.integer "contact_id"
    t.string  "padma_status"
  end

  create_table "attendance_contacts", force: true do |t|
    t.integer "attendance_id"
    t.integer "contact_id"
  end

  add_index "attendance_contacts", ["attendance_id"], name: "index_attendance_contacts_on_attendance_id"
  add_index "attendance_contacts", ["contact_id"], name: "index_attendance_contacts_on_contact_id"

  create_table "attendances", force: true do |t|
    t.integer  "account_id"
    t.integer  "time_slot_id"
    t.date     "attendance_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
  end

  add_index "attendances", ["account_id"], name: "index_attendances_on_account_id"
  add_index "attendances", ["time_slot_id"], name: "index_attendances_on_time_slot_id"

  create_table "contact_time_slots", force: true do |t|
    t.integer  "contact_id"
    t.integer  "time_slot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.integer  "account_id"
    t.string   "padma_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "external_sysname"
    t.string   "external_id"
    t.string   "padma_status"
  end

  add_index "contacts", ["account_id"], name: "index_contacts_on_account_id"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "import_details", force: true do |t|
    t.integer  "value"
    t.integer  "import_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
  end

  create_table "imports", force: true do |t|
    t.string   "type"
    t.integer  "account_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "headers"
    t.string   "csv_file"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "time_slots", force: true do |t|
    t.string   "padma_uid"
    t.integer  "account_id"
    t.string   "name"
    t.time     "start_at"
    t.time     "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.boolean  "sunday"
    t.boolean  "cultural_activity"
    t.text     "observations"
    t.string   "external_id"
    t.boolean  "unscheduled"
  end

  create_table "trial_lessons", force: true do |t|
    t.integer  "account_id"
    t.integer  "contact_id"
    t.integer  "time_slot_id"
    t.date     "trial_on"
    t.string   "padma_uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "assisted"
    t.boolean  "confirmed"
    t.boolean  "archived"
    t.string   "absence_reason"
  end

  add_index "trial_lessons", ["account_id"], name: "index_trial_lessons_on_account_id"
  add_index "trial_lessons", ["contact_id"], name: "index_trial_lessons_on_contact_id"
  add_index "trial_lessons", ["time_slot_id"], name: "index_trial_lessons_on_time_slot_id"

  create_table "users", force: true do |t|
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_account_id"
  end

end
