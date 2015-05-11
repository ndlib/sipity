################################################################################
#
# This file was generated by sipity:build_query_repository_interface rake task.
#
################################################################################
module Sipity
  class QueryRepositoryInterface
    # @see ./app/repositories/sipity/queries/attachment_queries.rb
    def access_rights_for_accessible_objects_of(work:)
    end

    # @see ./app/repositories/sipity/queries/attachment_queries.rb
    def accessible_objects(work:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def action_registers_subquery_builder(poly_type:, entity:, action:)
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

    # @see ./app/repositories/sipity/queries/enrichment_queries.rb
    def build_enrichment_form(attributes = {})
    end

    # @see ./app/repositories/sipity/queries/event_trigger_queries.rb
    def build_event_trigger_form(attributes = {})
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

    # @see ./app/repositories/sipity/queries/collaborator_queries.rb
    def collaborators_that_can_advance_the_current_state_of(work:, id: nil)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def collaborators_that_have_taken_the_action_on_the_entity(entity:, action:)
    end

    # @see ./app/repositories/sipity/queries/notification_queries.rb
    def email_notifications_for(reason:, scope:)
    end

    # @see ./app/repositories/sipity/queries/comment_queries.rb
    def find_comments_for_work(work:)
    end

    # @see ./app/repositories/sipity/queries/comment_queries.rb
    def find_current_comments_for_work(work:)
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

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def non_user_collaborators_that_have_taken_the_action_on_the_entity(entity:, action:)
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
    def scope_strategy_actions_with_incomplete_prerequisites(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_strategy_actions_without_prerequisites(entity:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def scope_users_for_entity_and_roles(entity:, roles:)
    end

    # @see ./app/repositories/sipity/queries/event_log_queries.rb
    def sequence_of_events_for(options = {})
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def user_emails_for_entity_and_roles(entity:, roles:)
    end

    # @see ./app/repositories/sipity/queries/processing_queries.rb
    def users_that_have_taken_the_action_on_the_entity(entity:, action:)
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
