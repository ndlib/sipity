################################################################################
#
# This file was generated by sipity:build_command_repository_interface rake task.
#
################################################################################
module Sipity
  class CommandRepositoryInterface
    # @see ./app/repositories/sipity/queries/attachment_queries.rb
    def accessible_objects(work:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def amend_files_metadata(work:, user:, metadata: {})
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def apply_access_policies_to(*)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def assign_collaborators_to(work:, collaborators:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def attach_files_to(work:, files:, user:, pid_minter: default_pid_minter)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def authorized_for_processing?(user:, entity:, action:)
    end

    # @see ./app/repositories/sipity/queries/account_profile_queries.rb
    def build_account_profile_form(attributes:)
    end

    # @see ./app/repositories/sipity/queries/citation_queries.rb
    def build_assign_a_citation_form(attributes = {})
    end

    # @see ./app/repositories/sipity/queries/doi_queries.rb
    def build_assign_a_doi_form(attributes = {})
    end

    # @see ./app/repositories/sipity/queries/account_placeholder_queries.rb
    def build_create_orcid_account_placeholder_form(attributes: {})
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def build_create_work_form(attributes: {})
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def build_dashboard_view(user:, filter: {})
    end

    # @see ./app/repositories/sipity/queries/enrichment_queries.rb
    def build_enrichment_form(attributes = {})
    end

    # @see ./app/repositories/sipity/queries/event_trigger_queries.rb
    def build_event_trigger_form(attributes = {})
    end

    # @see ./app/repositories/sipity/queries/doi_queries.rb
    def build_request_a_doi_form(attributes = {})
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def build_update_work_form(work:, attributes: {})
    end

    # @see ./app/repositories/sipity/queries/citation_queries.rb
    def citation_already_assigned?(work)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def create_sipity_user_from(netid:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def create_work!(attributes = {})
    end

    # @see ./app/repositories/sipity/commands/additional_attribute_commands.rb
    def create_work_attribute_values!(work:, key:, values:)
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def default_pid_minter
    end

    # @see ./app/repositories/sipity/commands/work_commands.rb
    def destroy_a_work(work:)
    end

    # @see ./app/repositories/sipity/commands/additional_attribute_commands.rb
    def destroy_work_attribute_values!(work:, key:, values:)
    end

    # @see ./app/repositories/sipity/queries/doi_queries.rb
    def doi_already_assigned?(work)
    end

    # @see ./app/repositories/sipity/queries/doi_queries.rb
    def doi_request_is_pending?(work)
    end

    # @see ./app/repositories/sipity/queries/permission_queries.rb
    def emails_for_associated_users(acting_as:, entity:)
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def existing_work_attributes_for(work)
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def exposed_work_attribute_names_for(work:, additional_attribute_names: BASE_HEADER_ATTRIBUTES)
    end

    # @see ./app/repositories/sipity/queries/doi_queries.rb
    def find_doi_creation_request(work:)
    end

    # @see ./app/repositories/sipity/queries/attachment_queries.rb
    def find_or_initialize_attachments_by(work:, pid:)
    end

    # @see ./app/repositories/sipity/queries/collaborator_queries.rb
    def find_or_initialize_collaborators_by(work:, id:, &block)
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def find_work(work_id)
    end

    # @see ./app/repositories/sipity/queries/work_queries.rb
    def find_works_for(user:, processing_state: nil)
    end

    # @see ./app/repositories/sipity/queries/doi_queries.rb
    def gather_doi_creation_request_metadata(work:)
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
    def mark_as_representative(work:, pid:, user: user)
    end

    # @see ./app/repositories/sipity/commands/todo_list_commands.rb
    def record_processing_comment(entity:, commenter:, action:, comment:)
    end

    # @see ./app/repositories/sipity/commands/todo_list_commands.rb
    def register_action_taken_on_entity(work:, enrichment_type:, requested_by:)
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
    def scope_proxied_objects_for_the_user_and_proxy_for_type(user:, proxy_for_type:, filter: {})
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_statetegy_actions_that_have_occurred(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_available_for_current_state(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_for_current_state(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_that_are_prerequisites(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_with_completed_prerequisites(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_with_incomplete_prerequisites(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_without_prerequisites(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_users_for_entity_and_roles(entity:, roles:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_users_from_actors(actors:)
    end

    # @see ./app/repositories/sipity/commands/notification_commands.rb
    def send_notification_for_entity_trigger(notification:, entity:, acting_as:)
    end

    # @see ./app/repositories/sipity/queries/event_log_queries.rb
    def sequence_of_events_for(options = {})
    end

    # @see ./app/repositories/sipity/commands/doi_commands.rb
    def submit_assign_a_doi_form(form, requested_by:)
    end

    # @see ./app/repositories/sipity/commands/doi_commands.rb
    def submit_doi_creation_request_job!(work:)
    end

    # @see ./app/repositories/sipity/commands/doi_commands.rb
    def submit_request_a_doi_form(form, requested_by:)
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

    # @see ./app/repositories/sipity/commands/doi_commands.rb
    def update_work_doi_creation_request_state!(work:, state:, response_message: nil)
    end

    # @see ./app/repositories/sipity/commands/additional_attribute_commands.rb
    def update_work_publication_date!(work:, publication_date:)
    end

    # @see ./app/repositories/sipity/queries/collaborator_queries.rb
    def usernames_of_those_that_are_collaborating_and_responsible_for_review(work:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def usernames_of_those_that_have_taken_the_action_on_the_entity(entity:, action:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def users_that_have_taken_the_action_on_the_entity(entity:, action:)
    end

    # @see ./app/repositories/sipity/queries/attachment_queries.rb
    def work_attachments(work:)
    end

    # @see ./app/repositories/sipity/queries/additional_attribute_queries.rb
    def work_attribute_key_value_pairs(work:, keys: [])
    end

    # @see ./app/repositories/sipity/queries/additional_attribute_queries.rb
    def work_attribute_keys_for(work:)
    end

    # @see ./app/repositories/sipity/queries/additional_attribute_queries.rb
    def work_attribute_values_for(work:, key:)
    end

    # @see ./app/repositories/sipity/queries/collaborator_queries.rb
    def work_collaborating_users_responsible_for_review(work:)
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

    # @see ./app/repositories/sipity/queries/additional_attribute_queries.rb
    def work_default_attribute_keys_for(*)
    end

  end
end
