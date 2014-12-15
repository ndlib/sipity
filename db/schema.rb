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

ActiveRecord::Schema.define(version: 20141215194110) do

  create_table "sipity_account_placeholders", force: true do |t|
    t.string   "identifier",                                     null: false
    t.string   "name"
    t.string   "identifier_type", limit: 32,                     null: false
    t.string   "state",           limit: 32, default: "created", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_account_placeholders", ["identifier", "identifier_type"], name: "sipity_account_placeholders_id_and_type", unique: true
  add_index "sipity_account_placeholders", ["identifier"], name: "index_sipity_account_placeholders_on_identifier"
  add_index "sipity_account_placeholders", ["name"], name: "index_sipity_account_placeholders_on_name"
  add_index "sipity_account_placeholders", ["state"], name: "index_sipity_account_placeholders_on_state"

  create_table "sipity_additional_attributes", force: true do |t|
    t.integer  "header_id",  null: false
    t.string   "key",        null: false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_additional_attributes", ["header_id", "key"], name: "index_sipity_additional_attributes_on_header_id_and_key"
  add_index "sipity_additional_attributes", ["header_id"], name: "index_sipity_additional_attributes_on_header_id"

  create_table "sipity_collaborators", force: true do |t|
    t.integer  "header_id",  null: false
    t.integer  "sequence"
    t.string   "name"
    t.string   "role",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_collaborators", ["header_id", "sequence"], name: "index_sipity_collaborators_on_header_id_and_sequence"

  create_table "sipity_doi_creation_requests", force: true do |t|
    t.integer  "header_id",                                              null: false
    t.string   "state",            default: "request_not_yet_submitted", null: false
    t.string   "response_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_doi_creation_requests", ["header_id"], name: "index_sipity_doi_creation_requests_on_header_id", unique: true
  add_index "sipity_doi_creation_requests", ["state"], name: "index_sipity_doi_creation_requests_on_state"

  create_table "sipity_event_logs", force: true do |t|
    t.integer  "user_id",                null: false
    t.integer  "entity_id",              null: false
    t.string   "entity_type", limit: 64, null: false
    t.string   "event_name",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_event_logs", ["created_at"], name: "index_sipity_event_logs_on_created_at"
  add_index "sipity_event_logs", ["entity_id", "entity_type", "event_name"], name: "sipity_event_logs_entity_event_name"
  add_index "sipity_event_logs", ["entity_id", "entity_type"], name: "sipity_event_logs_subject"
  add_index "sipity_event_logs", ["user_id", "created_at"], name: "index_sipity_event_logs_on_user_id_and_created_at"
  add_index "sipity_event_logs", ["user_id", "entity_id", "entity_type"], name: "sipity_event_logs_user_subject"
  add_index "sipity_event_logs", ["user_id", "event_name"], name: "sipity_event_logs_user_event_name"

  create_table "sipity_headers", force: true do |t|
    t.string   "work_publication_strategy"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sipity_permissions", force: true do |t|
    t.integer  "user_id",                null: false
    t.integer  "entity_id",              null: false
    t.string   "entity_type", limit: 64, null: false
    t.string   "role",        limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_permissions", ["entity_id", "entity_type", "role"], name: "sipity_permissions_entity_role"
  add_index "sipity_permissions", ["user_id", "entity_id", "entity_type"], name: "sipity_permissions_user_subject"
  add_index "sipity_permissions", ["user_id", "role"], name: "sipity_permissions_user_role"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "role"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
