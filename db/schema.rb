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

ActiveRecord::Schema.define(version: 20141204154424) do

  create_table "sip_additional_attributes", force: true do |t|
    t.integer  "sip_header_id", null: false
    t.string   "key",           null: false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sip_additional_attributes", ["sip_header_id", "key"], name: "index_sip_additional_attributes_on_sip_header_id_and_key"
  add_index "sip_additional_attributes", ["sip_header_id"], name: "index_sip_additional_attributes_on_sip_header_id"

  create_table "sip_collaborators", force: true do |t|
    t.integer  "sip_header_id", null: false
    t.integer  "sequence"
    t.string   "name"
    t.string   "role",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sip_collaborators", ["sip_header_id", "sequence"], name: "index_sip_collaborators_on_sip_header_id_and_sequence"

  create_table "sip_doi_creation_requests", force: true do |t|
    t.integer  "sip_header_id",    null: false
    t.string   "state",            null: false
    t.string   "response_message"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sip_doi_creation_requests", ["state"], name: "index_sip_doi_creation_requests_on_state"

  create_table "sip_headers", force: true do |t|
    t.string   "work_publication_strategy"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sip_permissions", force: true do |t|
    t.integer  "user_id",                 null: false
    t.integer  "subject_id",              null: false
    t.string   "subject_type", limit: 32, null: false
    t.string   "role",         limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sip_permissions", ["subject_id", "subject_type", "role"], name: "sip_permissions_subject_role"
  add_index "sip_permissions", ["user_id", "role"], name: "sip_permissions_user_role"
  add_index "sip_permissions", ["user_id", "subject_id", "subject_type"], name: "sip_permissions_user_subject"

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
