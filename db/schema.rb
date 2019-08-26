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

ActiveRecord::Schema.define(version: 2019_08_22_185902) do

  create_table "schema_migrations", primary_key: "version", id: :string, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
  end

  create_table "sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "sipity_access_rights", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "entity_id", limit: 32, null: false
    t.string "entity_type", null: false
    t.string "access_right_code", null: false
    t.date "transition_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id", "entity_type"], name: "index_sipity_access_rights_on_entity_id_and_entity_type", unique: true
  end

  create_table "sipity_account_placeholders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name"
    t.string "identifier_type", limit: 32, null: false
    t.string "state", limit: 32, default: "created", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["identifier", "identifier_type"], name: "sipity_account_placeholders_id_and_type", unique: true
    t.index ["identifier"], name: "index_sipity_account_placeholders_on_identifier"
    t.index ["name"], name: "index_sipity_account_placeholders_on_name"
    t.index ["state"], name: "index_sipity_account_placeholders_on_state"
  end

  create_table "sipity_additional_attributes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "work_id", limit: 32, null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["work_id", "key"], name: "index_sipity_additional_attributes_on_work_id_and_key"
    t.index ["work_id"], name: "index_sipity_additional_attributes_on_work_id"
  end

  create_table "sipity_agents", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "authentication_token", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authentication_token"], name: "index_sipity_agents_on_authentication_token", unique: true
    t.index ["name"], name: "index_sipity_agents_on_name", unique: true
  end

  create_table "sipity_attachments", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "work_id", limit: 32, null: false
    t.string "pid", null: false
    t.string "predicate_name", null: false
    t.string "file_uid", null: false
    t.string "file_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_representative_file", default: false
    t.index ["pid"], name: "index_sipity_attachments_on_pid", unique: true
    t.index ["work_id"], name: "index_sipity_attachments_on_work_id"
  end

  create_table "sipity_collaborators", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "work_id", limit: 32, null: false
    t.integer "sequence"
    t.string "name"
    t.string "role", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "netid"
    t.string "email"
    t.boolean "responsible_for_review", default: false
    t.index ["email"], name: "index_sipity_collaborators_on_email"
    t.index ["netid"], name: "index_sipity_collaborators_on_netid"
    t.index ["work_id", "email"], name: "index_sipity_collaborators_on_work_id_and_email", unique: true
    t.index ["work_id", "netid"], name: "index_sipity_collaborators_on_work_id_and_netid", unique: true
    t.index ["work_id", "sequence"], name: "index_sipity_collaborators_on_work_id_and_sequence"
  end

  create_table "sipity_doi_creation_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "work_id", limit: 32, null: false
    t.string "state", default: "request_not_yet_submitted", null: false
    t.string "response_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["state"], name: "index_sipity_doi_creation_requests_on_state"
    t.index ["work_id"], name: "index_sipity_doi_creation_requests_on_work_id", unique: true
  end

  create_table "sipity_event_logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "entity_id", limit: 32, null: false
    t.string "entity_type", limit: 64, null: false
    t.string "event_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "requested_by_id"
    t.string "requested_by_type"
    t.index ["created_at"], name: "index_sipity_event_logs_on_created_at"
    t.index ["entity_id", "entity_type", "event_name"], name: "sipity_event_logs_entity_action_name"
    t.index ["entity_id", "entity_type"], name: "sipity_event_logs_subject"
    t.index ["event_name"], name: "index_sipity_event_logs_on_event_name"
    t.index ["requested_by_type", "requested_by_id"], name: "idx_sipity_event_logs_on_requested_by"
    t.index ["user_id", "created_at"], name: "index_sipity_event_logs_on_user_id_and_created_at"
    t.index ["user_id", "entity_id", "entity_type"], name: "sipity_event_logs_user_subject"
    t.index ["user_id", "event_name"], name: "sipity_event_logs_user_event_name"
    t.index ["user_id"], name: "index_sipity_event_logs_on_user_id"
  end

  create_table "sipity_group_memberships", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "group_id", null: false
    t.string "membership_role", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["group_id", "membership_role"], name: "index_sipity_group_memberships_on_group_id_and_membership_role"
    t.index ["group_id", "user_id"], name: "index_sipity_group_memberships_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_sipity_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_sipity_group_memberships_on_user_id"
  end

  create_table "sipity_groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "api_key"
    t.index ["name", "api_key"], name: "index_sipity_groups_on_name_and_api_key"
    t.index ["name"], name: "index_sipity_groups_on_name", unique: true
  end

  create_table "sipity_models_processing_administrative_scheduled_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "scheduled_time", null: false
    t.string "reason", null: false
    t.string "entity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id", "reason"], name: "idx_sipity_scheduled_actions_entity_id_reason"
  end

  create_table "sipity_notification_email_recipients", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "email_id", null: false
    t.integer "role_id", null: false
    t.string "recipient_strategy", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_id", "role_id", "recipient_strategy"], name: "sipity_notification_email_recipients_surrogate"
    t.index ["email_id"], name: "sipity_notification_email_recipients_email"
    t.index ["recipient_strategy"], name: "sipity_notification_email_recipients_recipient_strategy"
    t.index ["role_id"], name: "sipity_notification_email_recipients_role"
  end

  create_table "sipity_notification_emails", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "method_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["method_name"], name: "index_sipity_notification_emails_on_method_name"
  end

  create_table "sipity_notification_notifiable_contexts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "scope_for_notification_id", null: false
    t.string "scope_for_notification_type", null: false
    t.string "reason_for_notification", null: false
    t.integer "email_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_id"], name: "idx_sipity_notification_notifiable_contexts_email_id"
    t.index ["scope_for_notification_id", "scope_for_notification_type", "reason_for_notification", "email_id"], name: "idx_sipity_notification_notifiable_contexts_concern_surrogate", unique: true
    t.index ["scope_for_notification_id", "scope_for_notification_type", "reason_for_notification"], name: "idx_sipity_notification_notifiable_contexts_concern_context"
    t.index ["scope_for_notification_id", "scope_for_notification_type"], name: "idx_sipity_notification_notifiable_contexts_concern"
  end

  create_table "sipity_processing_actors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "proxy_for_id", limit: 32, null: false
    t.string "proxy_for_type", null: false
    t.string "name_of_proxy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proxy_for_id", "proxy_for_type"], name: "sipity_processing_actors_proxy_for", unique: true
  end

  create_table "sipity_processing_comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "entity_id", limit: 32, null: false
    t.integer "actor_id", null: false
    t.text "comment"
    t.integer "originating_strategy_action_id", null: false
    t.integer "originating_strategy_state_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "stale", default: false
    t.index ["actor_id"], name: "index_sipity_processing_comments_on_actor_id"
    t.index ["created_at"], name: "index_sipity_processing_comments_on_created_at"
    t.index ["entity_id"], name: "index_sipity_processing_comments_on_entity_id"
    t.index ["originating_strategy_action_id"], name: "sipity_processing_comments_action_index"
    t.index ["originating_strategy_state_id"], name: "sipity_processing_comments_state_index"
  end

  create_table "sipity_processing_entities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "proxy_for_id", limit: 32, null: false
    t.string "proxy_for_type", null: false
    t.integer "strategy_id", null: false
    t.integer "strategy_state_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proxy_for_id", "proxy_for_type"], name: "sipity_processing_entities_proxy_for", unique: true
    t.index ["strategy_id"], name: "index_sipity_processing_entities_on_strategy_id"
    t.index ["strategy_state_id"], name: "index_sipity_processing_entities_on_strategy_state_id"
  end

  create_table "sipity_processing_entity_action_registers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "strategy_action_id", null: false
    t.string "entity_id", limit: 32, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "requested_by_actor_id", null: false
    t.integer "on_behalf_of_actor_id", null: false
    t.string "subject_id", null: false
    t.string "subject_type", null: false
    t.index ["strategy_action_id", "entity_id", "on_behalf_of_actor_id"], name: "sipity_processing_entity_action_registers_on_behalf"
    t.index ["strategy_action_id", "entity_id", "requested_by_actor_id"], name: "sipity_processing_entity_action_registers_requested"
    t.index ["strategy_action_id", "entity_id"], name: "sipity_processing_entity_action_registers_aggregate"
    t.index ["subject_id", "subject_type"], name: "sipity_processing_entity_action_registers_subject"
  end

  create_table "sipity_processing_entity_specific_responsibilities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "strategy_role_id", null: false
    t.string "entity_id", limit: 32, null: false
    t.integer "actor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "sipity_processing_entity_specific_responsibilities_actor"
    t.index ["entity_id"], name: "sipity_processing_entity_specific_responsibilities_entity"
    t.index ["strategy_role_id", "entity_id", "actor_id"], name: "sipity_processing_entity_specific_responsibilities_aggregate", unique: true
    t.index ["strategy_role_id"], name: "sipity_processing_entity_specific_responsibilities_role"
  end

  create_table "sipity_processing_strategies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sipity_processing_strategies_on_name", unique: true
  end

  create_table "sipity_processing_strategy_action_analogues", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "strategy_action_id", null: false
    t.integer "analogous_to_strategy_action_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analogous_to_strategy_action_id"], name: "ix_sipity_processing_strategy_action_analogues_analogous_stgy"
    t.index ["strategy_action_id", "analogous_to_strategy_action_id"], name: "ix_sipity_processing_strategy_action_analogues_aggregate", unique: true
    t.index ["strategy_action_id"], name: "ix_sipity_processing_strategy_action_analogues_strategy"
  end

  create_table "sipity_processing_strategy_action_prerequisites", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "guarded_strategy_action_id"
    t.integer "prerequisite_strategy_action_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guarded_strategy_action_id", "prerequisite_strategy_action_id"], name: "sipity_processing_strategy_action_prerequisites_aggregate", unique: true
  end

  create_table "sipity_processing_strategy_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "strategy_id", null: false
    t.integer "resulting_strategy_state_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "action_type", null: false
    t.integer "presentation_sequence"
    t.boolean "allow_repeat_within_current_state", default: true, null: false
    t.index ["action_type"], name: "index_sipity_processing_strategy_actions_on_action_type"
    t.index ["resulting_strategy_state_id"], name: "sipity_processing_strategy_actions_resulting_strategy_state"
    t.index ["strategy_id", "name"], name: "sipity_processing_strategy_actions_aggregate", unique: true
    t.index ["strategy_id", "presentation_sequence"], name: "sipity_processing_strategy_actions_sequence"
  end

  create_table "sipity_processing_strategy_responsibilities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "actor_id", null: false
    t.integer "strategy_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id", "strategy_role_id"], name: "sipity_processing_strategy_responsibilities_aggregate", unique: true
  end

  create_table "sipity_processing_strategy_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "strategy_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["strategy_id", "role_id"], name: "sipity_processing_strategy_roles_aggregate", unique: true
  end

  create_table "sipity_processing_strategy_state_action_permissions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "strategy_role_id", null: false
    t.integer "strategy_state_action_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["strategy_role_id", "strategy_state_action_id"], name: "sipity_processing_strategy_state_action_permissions_aggregate", unique: true
  end

  create_table "sipity_processing_strategy_state_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "originating_strategy_state_id", null: false
    t.integer "strategy_action_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["originating_strategy_state_id", "strategy_action_id"], name: "sipity_processing_strategy_state_actions_aggregate", unique: true
  end

  create_table "sipity_processing_strategy_states", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "strategy_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sipity_processing_strategy_states_on_name"
    t.index ["strategy_id", "name"], name: "sipity_processing_type_state_aggregate", unique: true
  end

  create_table "sipity_processing_strategy_usages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "strategy_id", null: false
    t.integer "usage_id", null: false
    t.string "usage_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["strategy_id"], name: "idx_sipity_processing_strategy_usages_strategy_fk"
    t.index ["usage_id", "usage_type"], name: "idx_sipity_processing_strategy_usages_usage_fk", unique: true
  end

  create_table "sipity_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sipity_roles_on_name", unique: true
  end

  create_table "sipity_submission_window_work_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "submission_window_id", null: false
    t.integer "work_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_window_id", "work_type_id"], name: "sipity_submission_window_work_types_surrogate", unique: true
    t.index ["submission_window_id"], name: "idx_sipity_submission_window_work_types_submission_window_id"
    t.index ["work_type_id"], name: "idx_sipity_submission_window_work_types_work_type_id"
  end

  create_table "sipity_submission_windows", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "work_area_id", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "open_for_starting_submissions_at"
    t.datetime "closed_for_starting_submissions_at"
    t.index ["closed_for_starting_submissions_at"], name: "idx_submission_windows_closed_surrogate"
    t.index ["open_for_starting_submissions_at"], name: "idx_submission_window_opening_at"
    t.index ["slug"], name: "index_sipity_submission_windows_on_slug"
    t.index ["work_area_id", "open_for_starting_submissions_at"], name: "idx_submission_windows_open_surrogate"
    t.index ["work_area_id", "slug"], name: "index_sipity_submission_windows_on_work_area_id_and_slug", unique: true
    t.index ["work_area_id"], name: "index_sipity_submission_windows_on_work_area_id"
  end

  create_table "sipity_work_areas", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "slug", null: false
    t.string "partial_suffix", null: false
    t.string "demodulized_class_prefix_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["name"], name: "index_sipity_work_areas_on_name", unique: true
    t.index ["slug"], name: "index_sipity_work_areas_on_slug", unique: true
  end

  create_table "sipity_work_redirect_strategies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "work_id", null: false
    t.string "url", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["work_id", "start_date"], name: "idx_work_redirect_strategies_surrogate"
  end

  create_table "sipity_work_submissions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "work_area_id", null: false
    t.integer "submission_window_id", null: false
    t.string "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_window_id", "work_id"], name: "idx_sipity_work_submissions_submission_window"
    t.index ["work_area_id", "work_id"], name: "idx_sipity_work_submissions_work_area"
    t.index ["work_id"], name: "idx_sipity_work_submissions_primary_key", unique: true
  end

  create_table "sipity_work_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sipity_work_types_on_name", unique: true
  end

  create_table "sipity_works", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "id", limit: 32, null: false
    t.text "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "work_type", null: false
    t.index ["id"], name: "index_sipity_works_on_id", unique: true
    t.index ["title"], name: "index_sipity_works_on_title", length: 64
    t.index ["work_type"], name: "index_sipity_works_on_work_type"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.integer "role"
    t.string "username", null: false
    t.boolean "agreed_to_terms_of_service", default: false
    t.string "provider"
    t.string "uid"
    t.index ["agreed_to_terms_of_service"], name: "index_users_on_agreed_to_terms_of_service"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
