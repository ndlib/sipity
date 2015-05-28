################################################################################
#
# This file was generated by sipity:build_command_repository_interface rake task.
#
################################################################################
module Sipity
  class CommandRepositoryInterface
    # @see ./app/repositories/sipity/queries/attachment_queries.rb
    def access_rights_for_accessible_objects_of(work:)
    end

    # @see ./app/repositories/sipity/queries/attachment_queries.rb
    def accessible_objects(work:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def action_registers_subquery_builder(poly_type:, entity:, actions:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def amend_files_metadata(work:, user:, metadata: {})
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def apply_access_policies_to(work:, user:, access_policies:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def assign_collaborators_to(work:, collaborators:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def attach_files_to(work:, files:, predicate_name: 'attachment', **keywords)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def authorized_for_processing?(user:, entity:, action:)
    end

    # @see ./app/repositories/sipity/queries/account_profile_queries.rb
    def build_account_profile_form(user:, attributes:)
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def build_create_work_form(attributes: {})
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def build_dashboard_view(user:, filter: {})
    end

    # @see ./app/repositories/sipity/queries/submission_window_queries.rb
    def build_submission_window_processing_action_form(submission_window:, processing_action_name:, attributes: {})
    end

    # @see ./app/repositories/sipity/queries/work_area_queries.rb
    def build_work_area_processing_action_form(work_area:, processing_action_name:, attributes: {})
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def build_work_submission_processing_action_form(work:, processing_action_name:, attributes: {})
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def change_processing_actor_proxy(from_proxy:, to_proxy:)
    end

    # @see ./app/repositories/sipity/queries/collaborator_queries.rb
    def collaborators_that_can_advance_the_current_state_of(work:, id: nil)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def collaborators_that_have_taken_the_action_on_the_entity(entity:, actions:)
    end

    # @see ./app/repositories/sipity/commands/notification_commands.rb
    def convert_recipient_roles_to_email(entity:, roles:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def create_sipity_user_from(netid:, email: nil)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def create_work!(submission_window:, **attributes)
    end

    # @see ./app/repositories/sipity/commands/additional_attribute_commands.rb
    def create_work_attribute_values!(work:, key:, values:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def default_email_for_netid(netid)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def default_pid_minter
    end

    # @see ./app/repositories/sipity/commands/notification_commands.rb
    def deliver_notification_for(scope:, the_thing:, **keywords)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def destroy_a_work(work:)
    end

    # @see ./app/repositories/sipity/commands/processing_commands.rb
    def destroy_existing_registered_state_changing_actions_for(entity:, strategy_state:)
    end

    # @see ./app/repositories/sipity/commands/additional_attribute_commands.rb
    def destroy_work_attribute_values!(work:, key:, values:)
    end

    # @see ./app/repositories/sipity/queries/notification_queries.rb
    def email_notifications_for(reason:, scope:)
    end

    # @see ./app/repositories/sipity/commands/processing_commands.rb
    def existing_registered_state_changing_actions_for(entity:, strategy_state:)
    end

    # @see ./app/repositories/sipity/queries/comment_queries.rb
    def find_comments_for(entity:)
    end

    # @see ./app/repositories/sipity/queries/comment_queries.rb
    def find_current_comments_for(entity:)
    end

    # @see ./app/repositories/sipity/queries/attachment_queries.rb
    def find_or_initialize_attachments_by(work:, pid:)
    end

    # @see ./app/repositories/sipity/queries/collaborator_queries.rb
    def find_or_initialize_collaborators_by(work:, id:, &block)
    end

    # @see ./app/repositories/sipity/queries/submission_window_queries.rb
    def find_submission_window_by(slug:, work_area:)
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def find_work(work_id)
    end

    # @see ./app/repositories/sipity/queries/work_area_queries.rb
    def find_work_area_by(slug:)
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def find_work_by(id:)
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def find_works_for(user:, processing_state: nil)
    end

    # @see ./app/repositories/sipity/queries/simple_controlled_vocabulary_queries.rb
    def get_controlled_vocabulary_entries_for_predicate_name(name:)
    end

    # @see ./app/repositories/sipity/queries/simple_controlled_vocabulary_queries.rb
    def get_controlled_vocabulary_value_for(name:, term_uri:)
    end

    # @see ./app/repositories/sipity/queries/simple_controlled_vocabulary_queries.rb
    def get_controlled_vocabulary_values_for_predicate_name(name:)
    end

    # @see ./app/repositories/sipity/commands/permission_commands.rb
    def grant_creating_user_permission_for!(entity:, user: nil, group: nil, actor: nil)
    end

    # @see ./app/repositories/sipity/commands/permission_commands.rb
    def grant_permission_for!(entity:, actors:, acting_as:)
    end

    # @see ./app/repositories/sipity/commands/permission_commands.rb
    def grant_processing_permission_for!(entity:, actor:, role:)
    end

    # @see ./app/repositories/sipity/commands/transient_answer_commands.rb
    def handle_transient_access_rights_answer(entity:, answer:)
    end

    # @see ./app/repositories/sipity/commands/event_log_commands.rb
    def log_event!(entity:, user:, event_name:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def manage_collaborators_for(work:, collaborators:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def non_user_collaborators_that_have_taken_the_action_on_the_entity(entity:, actions:)
    end

    # @see ./app/repositories/sipity/commands/todo_list_commands.rb
    def record_processing_comment(entity:, commenter:, action:, comment:)
    end

    # @see ./app/repositories/sipity/commands/todo_list_commands.rb
    def register_action_taken_on_entity(work:, action:, requested_by:, on_behalf_of: requested_by)
    end

    # @see ./app/repositories/sipity/commands/todo_list_commands.rb
    def register_processing_action_taken_on_entity(entity:, action:, requested_by:, on_behalf_of: requested_by)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def remove_files_from(work:, user:, pids:)
    end

    # @see ./app/repositories/sipity/queries/attachment_queries.rb
    def representative_attachment_for(work:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_permitted_entity_strategy_actions_for_current_state(user:, entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_permitted_entity_strategy_state_actions(user:, entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_permitted_strategy_actions_available_for_current_state(user:, entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_permitted_without_concern_for_repetition_entity_strategy_actions_for_current_state(user:, entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_processing_actors_for(user:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_processing_entities_for_the_user_and_proxy_for_type(user:, proxy_for_type:, filter: {})
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_processing_strategy_roles_for_user_and_entity(user:, entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_processing_strategy_roles_for_user_and_entity_specific(user:, entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_processing_strategy_roles_for_user_and_strategy(user:, strategy:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_proxied_objects_for_the_user_and_proxy_for_type(user:, proxy_for_type:, filter: {}, where: {})
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_statetegy_actions_that_have_occurred(entity:, pluck: nil)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_available_for_current_state(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_for_current_state(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_that_are_prerequisites(entity:, pluck: nil)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_with_completed_prerequisites(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_with_incomplete_prerequisites(entity:, pluck: nil)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_without_prerequisites(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_users_for_entity_and_roles(entity:, roles:)
    end

    # @see ./app/repositories/sipity/commands/notification_commands.rb
    def send_notification_for_entity_trigger(notification:, entity:, **roles_for_recipients)
    end

    # @see ./app/repositories/sipity/queries/event_log_queries.rb
    def sequence_of_events_for(options = {})
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def set_as_representative_attachment(work:, pid:)
    end

    # @see ./app/repositories/sipity/commands/todo_list_commands.rb
    def unregister_action_taken_on_entity(work:, action:, requested_by:, on_behalf_of: requested_by)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def update_processing_state!(entity:, to:)
    end

    # @see ./app/repositories/sipity/commands/account_profile_commands.rb
    def update_user_preferred_name(user:, preferred_name:)
    end

    # @see ./app/repositories/sipity/commands/additional_attribute_commands.rb
    def update_work_attribute_values!(work:, key:, values:)
    end

    # @see ./app/repositories/sipity/commands/additional_attribute_commands.rb
    def update_work_publication_date!(work:, publication_date:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def update_work_title!(work:, title:)
    end

    # @see ./app/repositories/sipity/commands/account_profile_commands.rb
    def user_agreed_to_terms_of_service(user:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def user_emails_for_entity_and_roles(entity:, roles:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def users_that_have_taken_the_action_on_the_entity(entity:, actions:)
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def work_access_right_codes(work:)
    end

    # @see ./app/repositories/sipity/queries/attachment_queries.rb
    def work_attachments(work:)
    end

    # @see ./app/repositories/sipity/queries/additional_attribute_queries.rb
    def work_attribute_key_value_pairs(work:, keys: [])
    end

    # @see ./app/repositories/sipity/queries/additional_attribute_queries.rb
    def work_attribute_values_for(work:, key:)
    end

    # @see ./app/repositories/sipity/queries/collaborator_queries.rb
    def work_collaborator_names_for(options = {})
    end

    # @see ./app/repositories/sipity/queries/collaborator_queries.rb
    def work_collaborators_for(options = {})
    end

    # @see ./app/repositories/sipity/queries/collaborator_queries.rb
    def work_collaborators_responsible_for_review(work:)
    end

  end
end
