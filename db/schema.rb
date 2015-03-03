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

ActiveRecord::Schema.define(version: 20150303172902) do

  create_table "sipity_access_rights", force: :cascade do |t|
    t.integer  "entity_id",         null: false
    t.string   "entity_type",       null: false
    t.string   "access_right_code", null: false
    t.date     "transition_date"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "sipity_access_rights", ["entity_id", "entity_type"], name: "index_sipity_access_rights_on_entity_id_and_entity_type", unique: true

  create_table "sipity_account_placeholders", force: :cascade do |t|
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

  create_table "sipity_additional_attributes", force: :cascade do |t|
    t.integer  "work_id",    null: false
    t.string   "key",        null: false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_additional_attributes", ["work_id", "key"], name: "index_sipity_additional_attributes_on_work_id_and_key"
  add_index "sipity_additional_attributes", ["work_id"], name: "index_sipity_additional_attributes_on_work_id"

  create_table "sipity_attachments", id: false, force: :cascade do |t|
    t.integer  "work_id",                                null: false
    t.string   "pid",                                    null: false
    t.string   "predicate_name",                         null: false
    t.string   "file_uid",                               null: false
    t.string   "file_name",                              null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "is_representative_file", default: false
  end

  add_index "sipity_attachments", ["pid"], name: "index_sipity_attachments_on_pid", unique: true
  add_index "sipity_attachments", ["work_id"], name: "index_sipity_attachments_on_work_id"

  create_table "sipity_collaborators", force: :cascade do |t|
    t.integer  "work_id",                                null: false
    t.integer  "sequence"
    t.string   "name"
    t.string   "role",                                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "netid"
    t.string   "email"
    t.boolean  "responsible_for_review", default: false
  end

  add_index "sipity_collaborators", ["email"], name: "index_sipity_collaborators_on_email"
  add_index "sipity_collaborators", ["netid"], name: "index_sipity_collaborators_on_netid"
  add_index "sipity_collaborators", ["work_id", "sequence"], name: "index_sipity_collaborators_on_work_id_and_sequence"

  create_table "sipity_doi_creation_requests", force: :cascade do |t|
    t.integer  "work_id",                                                null: false
    t.string   "state",            default: "request_not_yet_submitted", null: false
    t.string   "response_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_doi_creation_requests", ["state"], name: "index_sipity_doi_creation_requests_on_state"
  add_index "sipity_doi_creation_requests", ["work_id"], name: "index_sipity_doi_creation_requests_on_work_id", unique: true

  create_table "sipity_event_logs", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.integer  "entity_id",              null: false
    t.string   "entity_type", limit: 64, null: false
    t.string   "event_name",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_event_logs", ["created_at"], name: "index_sipity_event_logs_on_created_at"
  add_index "sipity_event_logs", ["entity_id", "entity_type", "event_name"], name: "sipity_event_logs_entity_action_name"
  add_index "sipity_event_logs", ["entity_id", "entity_type"], name: "sipity_event_logs_subject"
  add_index "sipity_event_logs", ["event_name"], name: "index_sipity_event_logs_on_event_name"
  add_index "sipity_event_logs", ["user_id", "created_at"], name: "index_sipity_event_logs_on_user_id_and_created_at"
  add_index "sipity_event_logs", ["user_id", "entity_id", "entity_type"], name: "sipity_event_logs_user_subject"
  add_index "sipity_event_logs", ["user_id", "event_name"], name: "sipity_event_logs_user_event_name"
  add_index "sipity_event_logs", ["user_id"], name: "index_sipity_event_logs_on_user_id"

  create_table "sipity_group_memberships", force: :cascade do |t|
    t.integer  "user_id",         null: false
    t.integer  "group_id",        null: false
    t.string   "membership_role", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_group_memberships", ["group_id", "membership_role"], name: "index_sipity_group_memberships_on_group_id_and_membership_role"
  add_index "sipity_group_memberships", ["group_id", "user_id"], name: "index_sipity_group_memberships_on_group_id_and_user_id", unique: true
  add_index "sipity_group_memberships", ["group_id"], name: "index_sipity_group_memberships_on_group_id"
  add_index "sipity_group_memberships", ["user_id"], name: "index_sipity_group_memberships_on_user_id"

  create_table "sipity_groups", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_groups", ["name"], name: "index_sipity_groups_on_name", unique: true

  create_table "sipity_processing_actors", force: :cascade do |t|
    t.integer  "proxy_for_id",   null: false
    t.string   "proxy_for_type", null: false
    t.string   "name_of_proxy"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "sipity_processing_actors", ["proxy_for_id", "proxy_for_type"], name: "sipity_processing_actors_proxy_for", unique: true

  create_table "sipity_processing_comments", force: :cascade do |t|
    t.integer  "entity_id",                      null: false
    t.integer  "actor_id",                       null: false
    t.text     "comment"
    t.integer  "originating_strategy_action_id", null: false
    t.integer  "originating_strategy_state_id",  null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "sipity_processing_comments", ["actor_id"], name: "index_sipity_processing_comments_on_actor_id"
  add_index "sipity_processing_comments", ["entity_id"], name: "index_sipity_processing_comments_on_entity_id"
  add_index "sipity_processing_comments", ["originating_strategy_action_id"], name: "sipity_processing_comments_action_index"
  add_index "sipity_processing_comments", ["originating_strategy_state_id"], name: "sipity_processing_comments_state_index"

  create_table "sipity_processing_entities", force: :cascade do |t|
    t.integer  "proxy_for_id",      null: false
    t.string   "proxy_for_type",    null: false
    t.integer  "strategy_id",       null: false
    t.integer  "strategy_state_id", null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "sipity_processing_entities", ["proxy_for_id", "proxy_for_type"], name: "sipity_processing_entities_proxy_for", unique: true
  add_index "sipity_processing_entities", ["strategy_id"], name: "index_sipity_processing_entities_on_strategy_id"
  add_index "sipity_processing_entities", ["strategy_state_id"], name: "index_sipity_processing_entities_on_strategy_state_id"

  create_table "sipity_processing_entity_action_registers", force: :cascade do |t|
    t.integer  "strategy_action_id",    null: false
    t.integer  "entity_id",             null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "requested_by_actor_id", null: false
    t.integer  "on_behalf_of_actor_id", null: false
  end

  add_index "sipity_processing_entity_action_registers", ["strategy_action_id", "entity_id", "on_behalf_of_actor_id"], name: "sipity_processing_entity_action_registers_on_behalf"
  add_index "sipity_processing_entity_action_registers", ["strategy_action_id", "entity_id", "requested_by_actor_id"], name: "sipity_processing_entity_action_registers_requested"
  add_index "sipity_processing_entity_action_registers", ["strategy_action_id", "entity_id"], name: "sipity_processing_entity_action_registers_aggregate"

  create_table "sipity_processing_entity_specific_responsibilities", force: :cascade do |t|
    t.integer  "strategy_role_id", null: false
    t.integer  "entity_id",        null: false
    t.integer  "actor_id",         null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "sipity_processing_entity_specific_responsibilities", ["actor_id"], name: "sipity_processing_entity_specific_responsibilities_actor"
  add_index "sipity_processing_entity_specific_responsibilities", ["entity_id"], name: "sipity_processing_entity_specific_responsibilities_entity"
  add_index "sipity_processing_entity_specific_responsibilities", ["strategy_role_id", "entity_id", "actor_id"], name: "sipity_processing_entity_specific_responsibilities_aggregate", unique: true
  add_index "sipity_processing_entity_specific_responsibilities", ["strategy_role_id"], name: "sipity_processing_entity_specific_responsibilities_role"

  create_table "sipity_processing_strategies", force: :cascade do |t|
    t.string   "name",           null: false
    t.text     "description"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "proxy_for_id",   null: false
    t.string   "proxy_for_type", null: false
  end

  add_index "sipity_processing_strategies", ["name"], name: "index_sipity_processing_strategies_on_name", unique: true
  add_index "sipity_processing_strategies", ["proxy_for_id", "proxy_for_type"], name: "sipity_processing_strategies_proxy_for", unique: true

  create_table "sipity_processing_strategy_action_prerequisites", force: :cascade do |t|
    t.integer  "guarded_strategy_action_id"
    t.integer  "prerequisite_strategy_action_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "sipity_processing_strategy_action_prerequisites", ["guarded_strategy_action_id", "prerequisite_strategy_action_id"], name: "sipity_processing_strategy_action_prerequisites_aggregate", unique: true

  create_table "sipity_processing_strategy_actions", force: :cascade do |t|
    t.integer  "strategy_id",                                 null: false
    t.integer  "resulting_strategy_state_id"
    t.string   "name",                                        null: false
    t.string   "form_class_name"
    t.boolean  "completion_required",         default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "action_type",                                 null: false
  end

  add_index "sipity_processing_strategy_actions", ["action_type"], name: "index_sipity_processing_strategy_actions_on_action_type"
  add_index "sipity_processing_strategy_actions", ["resulting_strategy_state_id"], name: "sipity_processing_strategy_actions_resulting_strategy_state"
  add_index "sipity_processing_strategy_actions", ["strategy_id", "name"], name: "sipity_processing_strategy_actions_aggregate", unique: true

  create_table "sipity_processing_strategy_responsibilities", force: :cascade do |t|
    t.integer  "actor_id",         null: false
    t.integer  "strategy_role_id", null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "sipity_processing_strategy_responsibilities", ["actor_id", "strategy_role_id"], name: "sipity_processing_strategy_responsibilities_aggregate", unique: true

  create_table "sipity_processing_strategy_roles", force: :cascade do |t|
    t.integer  "strategy_id", null: false
    t.integer  "role_id",     null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sipity_processing_strategy_roles", ["strategy_id", "role_id"], name: "sipity_processing_strategy_roles_aggregate", unique: true

  create_table "sipity_processing_strategy_state_action_permissions", force: :cascade do |t|
    t.integer  "strategy_role_id",         null: false
    t.integer  "strategy_state_action_id", null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "sipity_processing_strategy_state_action_permissions", ["strategy_role_id", "strategy_state_action_id"], name: "sipity_processing_strategy_state_action_permissions_aggregate", unique: true

  create_table "sipity_processing_strategy_state_actions", force: :cascade do |t|
    t.integer  "originating_strategy_state_id", null: false
    t.integer  "strategy_action_id",            null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "sipity_processing_strategy_state_actions", ["originating_strategy_state_id", "strategy_action_id"], name: "sipity_processing_strategy_state_actions_aggregate", unique: true

  create_table "sipity_processing_strategy_states", force: :cascade do |t|
    t.integer  "strategy_id", null: false
    t.string   "name",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sipity_processing_strategy_states", ["name"], name: "index_sipity_processing_strategy_states_on_name"
  add_index "sipity_processing_strategy_states", ["strategy_id", "name"], name: "sipity_processing_type_state_aggregate", unique: true

  create_table "sipity_roles", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sipity_roles", ["name"], name: "index_sipity_roles_on_name", unique: true

  create_table "sipity_transient_answers", force: :cascade do |t|
    t.integer  "entity_id",     null: false
    t.string   "entity_type",   null: false
    t.string   "question_code", null: false
    t.string   "answer_code",   null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "sipity_transient_answers", ["entity_id", "entity_type", "question_code"], name: "sipity_transient_entity_answers", unique: true
  add_index "sipity_transient_answers", ["entity_id", "entity_type"], name: "index_sipity_transient_answers_on_entity_id_and_entity_type"

  create_table "sipity_work_types", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "sipity_work_types", ["name"], name: "index_sipity_work_types_on_name", unique: true

  create_table "sipity_works", force: :cascade do |t|
    t.string   "work_publication_strategy"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "work_type",                 null: false
  end

  add_index "sipity_works", ["work_type"], name: "index_sipity_works_on_work_type"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "role"
    t.string   "username",                        null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
