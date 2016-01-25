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

ActiveRecord::Schema.define(version: 20160125135332) do

  create_table "data_migrations", id: false, force: :cascade do |t|
    t.string "version", limit: 255, null: false
  end

  add_index "data_migrations", ["version"], name: "unique_data_migrations", unique: true, using: :btree

  create_table "sipity_access_rights", force: :cascade do |t|
    t.string   "entity_id",         limit: 32,  null: false
    t.string   "entity_type",       limit: 255, null: false
    t.string   "access_right_code", limit: 255, null: false
    t.date     "transition_date"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "sipity_access_rights", ["entity_id", "entity_type"], name: "index_sipity_access_rights_on_entity_id_and_entity_type", unique: true, using: :btree

  create_table "sipity_account_placeholders", force: :cascade do |t|
    t.string   "identifier",      limit: 255,                     null: false
    t.string   "name",            limit: 255
    t.string   "identifier_type", limit: 32,                      null: false
    t.string   "state",           limit: 32,  default: "created", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_account_placeholders", ["identifier", "identifier_type"], name: "sipity_account_placeholders_id_and_type", unique: true, using: :btree
  add_index "sipity_account_placeholders", ["identifier"], name: "index_sipity_account_placeholders_on_identifier", using: :btree
  add_index "sipity_account_placeholders", ["name"], name: "index_sipity_account_placeholders_on_name", using: :btree
  add_index "sipity_account_placeholders", ["state"], name: "index_sipity_account_placeholders_on_state", using: :btree

  create_table "sipity_additional_attributes", force: :cascade do |t|
    t.string   "work_id",    limit: 32,    null: false
    t.string   "key",        limit: 255,   null: false
    t.text     "value",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_additional_attributes", ["work_id", "key"], name: "index_sipity_additional_attributes_on_work_id_and_key", using: :btree
  add_index "sipity_additional_attributes", ["work_id"], name: "index_sipity_additional_attributes_on_work_id", using: :btree

  create_table "sipity_agents", force: :cascade do |t|
    t.string   "name",                 limit: 255,               null: false
    t.text     "description",          limit: 65535
    t.string   "authentication_token", limit: 255,               null: false
    t.integer  "sign_in_count",        limit: 4,     default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",   limit: 255
    t.string   "last_sign_in_ip",      limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "sipity_agents", ["authentication_token"], name: "index_sipity_agents_on_authentication_token", unique: true, using: :btree
  add_index "sipity_agents", ["name"], name: "index_sipity_agents_on_name", unique: true, using: :btree

  create_table "sipity_attachments", id: false, force: :cascade do |t|
    t.string   "work_id",                limit: 32,                  null: false
    t.string   "pid",                    limit: 255,                 null: false
    t.string   "predicate_name",         limit: 255,                 null: false
    t.string   "file_uid",               limit: 255,                 null: false
    t.string   "file_name",              limit: 255,                 null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "is_representative_file",             default: false
  end

  add_index "sipity_attachments", ["pid"], name: "index_sipity_attachments_on_pid", unique: true, using: :btree
  add_index "sipity_attachments", ["work_id"], name: "index_sipity_attachments_on_work_id", using: :btree

  create_table "sipity_collaborators", force: :cascade do |t|
    t.string   "work_id",                limit: 32,                  null: false
    t.integer  "sequence",               limit: 4
    t.string   "name",                   limit: 255
    t.string   "role",                   limit: 255,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "netid",                  limit: 255
    t.string   "email",                  limit: 255
    t.boolean  "responsible_for_review",             default: false
  end

  add_index "sipity_collaborators", ["email"], name: "index_sipity_collaborators_on_email", using: :btree
  add_index "sipity_collaborators", ["netid"], name: "index_sipity_collaborators_on_netid", using: :btree
  add_index "sipity_collaborators", ["work_id", "email"], name: "index_sipity_collaborators_on_work_id_and_email", unique: true, using: :btree
  add_index "sipity_collaborators", ["work_id", "netid"], name: "index_sipity_collaborators_on_work_id_and_netid", unique: true, using: :btree
  add_index "sipity_collaborators", ["work_id", "sequence"], name: "index_sipity_collaborators_on_work_id_and_sequence", using: :btree

  create_table "sipity_doi_creation_requests", force: :cascade do |t|
    t.string   "work_id",          limit: 32,                                        null: false
    t.string   "state",            limit: 255, default: "request_not_yet_submitted", null: false
    t.string   "response_message", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_doi_creation_requests", ["state"], name: "index_sipity_doi_creation_requests_on_state", using: :btree
  add_index "sipity_doi_creation_requests", ["work_id"], name: "index_sipity_doi_creation_requests_on_work_id", unique: true, using: :btree

  create_table "sipity_event_logs", force: :cascade do |t|
    t.integer  "user_id",           limit: 4,   null: false
    t.string   "entity_id",         limit: 32,  null: false
    t.string   "entity_type",       limit: 64,  null: false
    t.string   "event_name",        limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "requested_by_id",   limit: 4
    t.string   "requested_by_type", limit: 255
  end

  add_index "sipity_event_logs", ["created_at"], name: "index_sipity_event_logs_on_created_at", using: :btree
  add_index "sipity_event_logs", ["entity_id", "entity_type", "event_name"], name: "sipity_event_logs_entity_action_name", using: :btree
  add_index "sipity_event_logs", ["entity_id", "entity_type"], name: "sipity_event_logs_subject", using: :btree
  add_index "sipity_event_logs", ["event_name"], name: "index_sipity_event_logs_on_event_name", using: :btree
  add_index "sipity_event_logs", ["requested_by_type", "requested_by_id"], name: "idx_sipity_event_logs_on_requested_by", using: :btree
  add_index "sipity_event_logs", ["user_id", "created_at"], name: "index_sipity_event_logs_on_user_id_and_created_at", using: :btree
  add_index "sipity_event_logs", ["user_id", "entity_id", "entity_type"], name: "sipity_event_logs_user_subject", using: :btree
  add_index "sipity_event_logs", ["user_id", "event_name"], name: "sipity_event_logs_user_event_name", using: :btree
  add_index "sipity_event_logs", ["user_id"], name: "index_sipity_event_logs_on_user_id", using: :btree

  create_table "sipity_group_memberships", force: :cascade do |t|
    t.integer  "user_id",         limit: 4,   null: false
    t.integer  "group_id",        limit: 4,   null: false
    t.string   "membership_role", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_group_memberships", ["group_id", "membership_role"], name: "index_sipity_group_memberships_on_group_id_and_membership_role", using: :btree
  add_index "sipity_group_memberships", ["group_id", "user_id"], name: "index_sipity_group_memberships_on_group_id_and_user_id", unique: true, using: :btree
  add_index "sipity_group_memberships", ["group_id"], name: "index_sipity_group_memberships_on_group_id", using: :btree
  add_index "sipity_group_memberships", ["user_id"], name: "index_sipity_group_memberships_on_user_id", using: :btree

  create_table "sipity_groups", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sipity_groups", ["name"], name: "index_sipity_groups_on_name", unique: true, using: :btree

  create_table "sipity_models_processing_administrative_scheduled_actions", force: :cascade do |t|
    t.datetime "scheduled_time",             null: false
    t.string   "reason",         limit: 255, null: false
    t.string   "entity_id",      limit: 255, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "sipity_models_processing_administrative_scheduled_actions", ["entity_id", "reason"], name: "idx_sipity_scheduled_actions_entity_id_reason", using: :btree

  create_table "sipity_notification_email_recipients", force: :cascade do |t|
    t.integer  "email_id",           limit: 4,   null: false
    t.integer  "role_id",            limit: 4,   null: false
    t.string   "recipient_strategy", limit: 255, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "sipity_notification_email_recipients", ["email_id", "role_id", "recipient_strategy"], name: "sipity_notification_email_recipients_surrogate", using: :btree
  add_index "sipity_notification_email_recipients", ["email_id"], name: "sipity_notification_email_recipients_email", using: :btree
  add_index "sipity_notification_email_recipients", ["recipient_strategy"], name: "sipity_notification_email_recipients_recipient_strategy", using: :btree
  add_index "sipity_notification_email_recipients", ["role_id"], name: "sipity_notification_email_recipients_role", using: :btree

  create_table "sipity_notification_emails", force: :cascade do |t|
    t.string   "method_name", limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "sipity_notification_emails", ["method_name"], name: "index_sipity_notification_emails_on_method_name", using: :btree

  create_table "sipity_notification_notifiable_contexts", force: :cascade do |t|
    t.integer  "scope_for_notification_id",   limit: 4,   null: false
    t.string   "scope_for_notification_type", limit: 255, null: false
    t.string   "reason_for_notification",     limit: 255, null: false
    t.integer  "email_id",                    limit: 4,   null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "sipity_notification_notifiable_contexts", ["email_id"], name: "idx_sipity_notification_notifiable_contexts_email_id", using: :btree
  add_index "sipity_notification_notifiable_contexts", ["scope_for_notification_id", "scope_for_notification_type", "reason_for_notification", "email_id"], name: "idx_sipity_notification_notifiable_contexts_concern_surrogate", unique: true, using: :btree
  add_index "sipity_notification_notifiable_contexts", ["scope_for_notification_id", "scope_for_notification_type", "reason_for_notification"], name: "idx_sipity_notification_notifiable_contexts_concern_context", using: :btree
  add_index "sipity_notification_notifiable_contexts", ["scope_for_notification_id", "scope_for_notification_type"], name: "idx_sipity_notification_notifiable_contexts_concern", using: :btree

  create_table "sipity_processing_actors", force: :cascade do |t|
    t.string   "proxy_for_id",   limit: 32,  null: false
    t.string   "proxy_for_type", limit: 255, null: false
    t.string   "name_of_proxy",  limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "sipity_processing_actors", ["proxy_for_id", "proxy_for_type"], name: "sipity_processing_actors_proxy_for", unique: true, using: :btree

  create_table "sipity_processing_comments", force: :cascade do |t|
    t.string   "entity_id",                      limit: 32,                    null: false
    t.integer  "actor_id",                       limit: 4,                     null: false
    t.text     "comment",                        limit: 65535
    t.integer  "originating_strategy_action_id", limit: 4,                     null: false
    t.integer  "originating_strategy_state_id",  limit: 4,                     null: false
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.boolean  "stale",                                        default: false
  end

  add_index "sipity_processing_comments", ["actor_id"], name: "index_sipity_processing_comments_on_actor_id", using: :btree
  add_index "sipity_processing_comments", ["created_at"], name: "index_sipity_processing_comments_on_created_at", using: :btree
  add_index "sipity_processing_comments", ["entity_id"], name: "index_sipity_processing_comments_on_entity_id", using: :btree
  add_index "sipity_processing_comments", ["originating_strategy_action_id"], name: "sipity_processing_comments_action_index", using: :btree
  add_index "sipity_processing_comments", ["originating_strategy_state_id"], name: "sipity_processing_comments_state_index", using: :btree

  create_table "sipity_processing_entities", force: :cascade do |t|
    t.string   "proxy_for_id",      limit: 32,  null: false
    t.string   "proxy_for_type",    limit: 255, null: false
    t.integer  "strategy_id",       limit: 4,   null: false
    t.integer  "strategy_state_id", limit: 4,   null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "sipity_processing_entities", ["proxy_for_id", "proxy_for_type"], name: "sipity_processing_entities_proxy_for", unique: true, using: :btree
  add_index "sipity_processing_entities", ["strategy_id"], name: "index_sipity_processing_entities_on_strategy_id", using: :btree
  add_index "sipity_processing_entities", ["strategy_state_id"], name: "index_sipity_processing_entities_on_strategy_state_id", using: :btree

  create_table "sipity_processing_entity_action_registers", force: :cascade do |t|
    t.integer  "strategy_action_id",    limit: 4,   null: false
    t.string   "entity_id",             limit: 32,  null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "requested_by_actor_id", limit: 4,   null: false
    t.integer  "on_behalf_of_actor_id", limit: 4,   null: false
    t.string   "subject_id",            limit: 255, null: false
    t.string   "subject_type",          limit: 255, null: false
  end

  add_index "sipity_processing_entity_action_registers", ["strategy_action_id", "entity_id", "on_behalf_of_actor_id"], name: "sipity_processing_entity_action_registers_on_behalf", using: :btree
  add_index "sipity_processing_entity_action_registers", ["strategy_action_id", "entity_id", "requested_by_actor_id"], name: "sipity_processing_entity_action_registers_requested", using: :btree
  add_index "sipity_processing_entity_action_registers", ["strategy_action_id", "entity_id"], name: "sipity_processing_entity_action_registers_aggregate", using: :btree
  add_index "sipity_processing_entity_action_registers", ["subject_id", "subject_type"], name: "sipity_processing_entity_action_registers_subject", using: :btree

  create_table "sipity_processing_entity_specific_responsibilities", force: :cascade do |t|
    t.integer  "strategy_role_id", limit: 4,  null: false
    t.string   "entity_id",        limit: 32, null: false
    t.integer  "actor_id",         limit: 4,  null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "sipity_processing_entity_specific_responsibilities", ["actor_id"], name: "sipity_processing_entity_specific_responsibilities_actor", using: :btree
  add_index "sipity_processing_entity_specific_responsibilities", ["entity_id"], name: "sipity_processing_entity_specific_responsibilities_entity", using: :btree
  add_index "sipity_processing_entity_specific_responsibilities", ["strategy_role_id", "entity_id", "actor_id"], name: "sipity_processing_entity_specific_responsibilities_aggregate", unique: true, using: :btree
  add_index "sipity_processing_entity_specific_responsibilities", ["strategy_role_id"], name: "sipity_processing_entity_specific_responsibilities_role", using: :btree

  create_table "sipity_processing_strategies", force: :cascade do |t|
    t.string   "name",        limit: 255,   null: false
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "sipity_processing_strategies", ["name"], name: "index_sipity_processing_strategies_on_name", unique: true, using: :btree

  create_table "sipity_processing_strategy_action_analogues", force: :cascade do |t|
    t.integer  "strategy_action_id",              limit: 4, null: false
    t.integer  "analogous_to_strategy_action_id", limit: 4, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "sipity_processing_strategy_action_analogues", ["analogous_to_strategy_action_id"], name: "ix_sipity_processing_strategy_action_analogues_analogous_stgy", using: :btree
  add_index "sipity_processing_strategy_action_analogues", ["strategy_action_id", "analogous_to_strategy_action_id"], name: "ix_sipity_processing_strategy_action_analogues_aggregate", unique: true, using: :btree
  add_index "sipity_processing_strategy_action_analogues", ["strategy_action_id"], name: "ix_sipity_processing_strategy_action_analogues_strategy", using: :btree

  create_table "sipity_processing_strategy_action_prerequisites", force: :cascade do |t|
    t.integer  "guarded_strategy_action_id",      limit: 4
    t.integer  "prerequisite_strategy_action_id", limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "sipity_processing_strategy_action_prerequisites", ["guarded_strategy_action_id", "prerequisite_strategy_action_id"], name: "sipity_processing_strategy_action_prerequisites_aggregate", unique: true, using: :btree

  create_table "sipity_processing_strategy_actions", force: :cascade do |t|
    t.integer  "strategy_id",                       limit: 4,                  null: false
    t.integer  "resulting_strategy_state_id",       limit: 4
    t.string   "name",                              limit: 255,                null: false
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "action_type",                       limit: 255,                null: false
    t.integer  "presentation_sequence",             limit: 4
    t.boolean  "allow_repeat_within_current_state",             default: true, null: false
  end

  add_index "sipity_processing_strategy_actions", ["action_type"], name: "index_sipity_processing_strategy_actions_on_action_type", using: :btree
  add_index "sipity_processing_strategy_actions", ["resulting_strategy_state_id"], name: "sipity_processing_strategy_actions_resulting_strategy_state", using: :btree
  add_index "sipity_processing_strategy_actions", ["strategy_id", "name"], name: "sipity_processing_strategy_actions_aggregate", unique: true, using: :btree
  add_index "sipity_processing_strategy_actions", ["strategy_id", "presentation_sequence"], name: "sipity_processing_strategy_actions_sequence", using: :btree

  create_table "sipity_processing_strategy_responsibilities", force: :cascade do |t|
    t.integer  "actor_id",         limit: 4, null: false
    t.integer  "strategy_role_id", limit: 4, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "sipity_processing_strategy_responsibilities", ["actor_id", "strategy_role_id"], name: "sipity_processing_strategy_responsibilities_aggregate", unique: true, using: :btree

  create_table "sipity_processing_strategy_roles", force: :cascade do |t|
    t.integer  "strategy_id", limit: 4, null: false
    t.integer  "role_id",     limit: 4, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "sipity_processing_strategy_roles", ["strategy_id", "role_id"], name: "sipity_processing_strategy_roles_aggregate", unique: true, using: :btree

  create_table "sipity_processing_strategy_state_action_permissions", force: :cascade do |t|
    t.integer  "strategy_role_id",         limit: 4, null: false
    t.integer  "strategy_state_action_id", limit: 4, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "sipity_processing_strategy_state_action_permissions", ["strategy_role_id", "strategy_state_action_id"], name: "sipity_processing_strategy_state_action_permissions_aggregate", unique: true, using: :btree

  create_table "sipity_processing_strategy_state_actions", force: :cascade do |t|
    t.integer  "originating_strategy_state_id", limit: 4, null: false
    t.integer  "strategy_action_id",            limit: 4, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "sipity_processing_strategy_state_actions", ["originating_strategy_state_id", "strategy_action_id"], name: "sipity_processing_strategy_state_actions_aggregate", unique: true, using: :btree

  create_table "sipity_processing_strategy_states", force: :cascade do |t|
    t.integer  "strategy_id", limit: 4,   null: false
    t.string   "name",        limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "sipity_processing_strategy_states", ["name"], name: "index_sipity_processing_strategy_states_on_name", using: :btree
  add_index "sipity_processing_strategy_states", ["strategy_id", "name"], name: "sipity_processing_type_state_aggregate", unique: true, using: :btree

  create_table "sipity_processing_strategy_usages", force: :cascade do |t|
    t.integer  "strategy_id", limit: 4,   null: false
    t.integer  "usage_id",    limit: 4,   null: false
    t.string   "usage_type",  limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "sipity_processing_strategy_usages", ["strategy_id"], name: "idx_sipity_processing_strategy_usages_strategy_fk", using: :btree
  add_index "sipity_processing_strategy_usages", ["usage_id", "usage_type"], name: "idx_sipity_processing_strategy_usages_usage_fk", unique: true, using: :btree

  create_table "sipity_roles", force: :cascade do |t|
    t.string   "name",        limit: 255,   null: false
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "sipity_roles", ["name"], name: "index_sipity_roles_on_name", unique: true, using: :btree

  create_table "sipity_submission_window_work_types", force: :cascade do |t|
    t.integer  "submission_window_id", limit: 4, null: false
    t.integer  "work_type_id",         limit: 4, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "sipity_submission_window_work_types", ["submission_window_id", "work_type_id"], name: "sipity_submission_window_work_types_surrogate", unique: true, using: :btree
  add_index "sipity_submission_window_work_types", ["submission_window_id"], name: "idx_sipity_submission_window_work_types_submission_window_id", using: :btree
  add_index "sipity_submission_window_work_types", ["work_type_id"], name: "idx_sipity_submission_window_work_types_work_type_id", using: :btree

  create_table "sipity_submission_windows", force: :cascade do |t|
    t.integer  "work_area_id",                       limit: 4,   null: false
    t.string   "slug",                               limit: 255, null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.datetime "open_for_starting_submissions_at"
    t.datetime "closed_for_starting_submissions_at"
  end

  add_index "sipity_submission_windows", ["closed_for_starting_submissions_at"], name: "idx_submission_windows_closed_surrogate", using: :btree
  add_index "sipity_submission_windows", ["open_for_starting_submissions_at"], name: "idx_submission_window_opening_at", using: :btree
  add_index "sipity_submission_windows", ["slug"], name: "index_sipity_submission_windows_on_slug", using: :btree
  add_index "sipity_submission_windows", ["work_area_id", "open_for_starting_submissions_at"], name: "idx_submission_windows_open_surrogate", using: :btree
  add_index "sipity_submission_windows", ["work_area_id", "slug"], name: "index_sipity_submission_windows_on_work_area_id_and_slug", unique: true, using: :btree
  add_index "sipity_submission_windows", ["work_area_id"], name: "index_sipity_submission_windows_on_work_area_id", using: :btree

  create_table "sipity_work_areas", force: :cascade do |t|
    t.string   "slug",                          limit: 255, null: false
    t.string   "partial_suffix",                limit: 255, null: false
    t.string   "demodulized_class_prefix_name", limit: 255, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "name",                          limit: 255, null: false
  end

  add_index "sipity_work_areas", ["name"], name: "index_sipity_work_areas_on_name", unique: true, using: :btree
  add_index "sipity_work_areas", ["slug"], name: "index_sipity_work_areas_on_slug", unique: true, using: :btree

  create_table "sipity_work_redirect_strategies", force: :cascade do |t|
    t.string   "work_id",    limit: 255, null: false
    t.string   "url",        limit: 255, null: false
    t.date     "start_date",             null: false
    t.date     "end_date"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "sipity_work_redirect_strategies", ["work_id", "start_date"], name: "idx_work_redirect_strategies_surrogate", using: :btree

  create_table "sipity_work_submissions", force: :cascade do |t|
    t.integer  "work_area_id",         limit: 4,   null: false
    t.integer  "submission_window_id", limit: 4,   null: false
    t.string   "work_id",              limit: 255, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "sipity_work_submissions", ["submission_window_id", "work_id"], name: "idx_sipity_work_submissions_submission_window", using: :btree
  add_index "sipity_work_submissions", ["work_area_id", "work_id"], name: "idx_sipity_work_submissions_work_area", using: :btree
  add_index "sipity_work_submissions", ["work_id"], name: "idx_sipity_work_submissions_primary_key", unique: true, using: :btree

  create_table "sipity_work_types", force: :cascade do |t|
    t.string   "name",        limit: 255,   null: false
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "sipity_work_types", ["name"], name: "index_sipity_work_types_on_name", unique: true, using: :btree

  create_table "sipity_works", id: false, force: :cascade do |t|
    t.string   "id",         limit: 32,    null: false
    t.text     "title",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "work_type",  limit: 255,   null: false
  end

  add_index "sipity_works", ["id"], name: "index_sipity_works_on_id", unique: true, using: :btree
  add_index "sipity_works", ["title"], name: "index_sipity_works_on_title", length: {"title"=>64}, using: :btree
  add_index "sipity_works", ["work_type"], name: "index_sipity_works_on_work_type", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                      limit: 255
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",         limit: 255
    t.string   "last_sign_in_ip",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                       limit: 255
    t.integer  "role",                       limit: 4
    t.string   "username",                   limit: 255,                 null: false
    t.boolean  "agreed_to_terms_of_service",             default: false
  end

  add_index "users", ["agreed_to_terms_of_service"], name: "index_users_on_agreed_to_terms_of_service", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
