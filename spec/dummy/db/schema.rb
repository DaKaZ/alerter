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

ActiveRecord::Schema.define(version: 20150821000000) do

  create_table "alerter_messages", force: :cascade do |t|
    t.string   "type"
    t.string   "short_msg",            default: ""
    t.text     "long_msg",             default: ""
    t.boolean  "draft",                default: false
    t.string   "notification_code"
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.integer  "notification_type_id"
    t.string   "attachment"
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  create_table "alerter_notification_types", force: :cascade do |t|
    t.string "name"
  end

  create_table "alerter_preferences", force: :cascade do |t|
    t.integer "notification_type_id"
    t.integer "notifiable_id"
    t.string  "notifiable_type"
    t.text    "alert_methods"
  end

  create_table "alerter_receipts", force: :cascade do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "message_id",                               null: false
    t.boolean  "is_read",                  default: false
    t.boolean  "deleted",                  default: false
    t.string   "mailbox_type",  limit: 25
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "alerter_receipts", ["message_id"], name: "index_alerter_receipts_on_message_id"

  create_table "cylons", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ducks", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
