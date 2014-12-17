module Sipity
  module StateMachines
    # Responsible for overseeing the life cycle of the ETD Submisssion process.
    #
    # TODO: Magic Strings Everywhere! Deal with them.
    #
    # REVIEW: How is this different from crafting a handful of runners? Perhaps
    #   These should be codified as runners? Is there a symmetry of moving these
    #   to runners? Is symmetry worth pursuing?
    class EtdStudentSubmission
      # TODO: Extract policy questions into separate class; There is a
      # relationship, but is this necessary.
      #
      # { state => { policy_question => roles } }
      STATE_POLICY_QUESTION_ROLE_MAP =
      {
        new: {
          update?: ['creating_user', 'advisor'], show?: ['creating_user', 'advisor'],
          delete?: ['creating_user'], submit_for_review?: ['creating_user']
        },
        under_review: {
          update?: ['etd_reviewer'], show?: ['creating_user', 'advisor', 'etd_reviewer'],
          request_revisions?: ['etd_reviewer'], approve_for_ingest?: ['etd_reviewer']
        },
        ready_for_ingest: { show?: ['creating_user', 'advisor', 'etd_reviewer'] },
        ingested: { show?: ['creating_user', 'advisor', 'etd_reviewer'] },
        ready_for_cataloging: { show?: ['creating_user', 'advisor', 'etd_reviewer', 'cataloger'], finish_cataloging?: ['cataloger'] },
        cataloged: { show?: ['creating_user', 'advisor', 'etd_reviewer', 'cataloger'] },
        done: { show?: ['creating_user', 'advisor', 'etd_reviewer', 'cataloger'] }
      }.freeze

      def initialize(entity:, user:, repository: nil)
        @entity, @user = entity, user
        @repository = repository || default_repository
        # @TODO - Catch unexpected states.
        @state_machine = build_state_machine
      end
      attr_reader :entity, :state_machine, :user, :repository
      private :entity, :state_machine, :user, :repository

      def roles_for_policy_question(policy_question)
        # @TODO - Catch invalid state look up
        STATE_POLICY_QUESTION_ROLE_MAP.fetch(entity.processing_state).fetch(policy_question, [])
      rescue KeyError
        raise Exceptions::StatePolicyQuestionRoleMapError, state: entity.processing_state, context: self
      end

      def trigger!(event, options = {})
        state_machine.trigger!(event)
        after_trigger_successful!(event, options)
      end

      private

      def after_trigger_successful!(event, options = {})
        repository.update_processing_state!(entity: entity, from: entity.processing_state, to: state_machine.state)
        repository.log_event!(entity: entity, user: user, event_name: convert_to_logged_name(event))
        include_private_methods = true
        send("after_trigger_#{event}", options) if respond_to?("after_trigger_#{event}", include_private_methods)
      end

      def after_trigger_submit_for_review(_options)
        repository.assign_group_roles_to_entity(entity: entity, roles: 'etd_reviewer')
        repository.send_notification(
          notification: "confirmation_of_entity_submitted_for_review", entity: entity, to_roles: 'creating_user'
        )
        repository.send_notification(notification: "entity_ready_for_review", entity: entity, to_roles: 'etd_reviewer')
      end

      def after_trigger_request_revisions(options)
        comments = options.fetch(:comments)
        repository.send_notification(
          notification: "request_revisions_from_creator", entity: entity, to_roles: 'creating_user', comments: comments
        )
      end

      def after_trigger_approve_for_ingest(_options)
        repository.submit_etd_student_submission_trigger!(entity: entity, trigger: :ingest, user: user)
      end

      def after_trigger_ingest(_options)
        repository.submit_ingest_etd(entity: entity)
      end

      def after_trigger_ingest_completed(options)
        repository.assign_group_roles_to_entity(entity: entity, roles: 'cataloger')
        additional_emails = options.fetch(:additional_emails)
        repository.send_notification(notification: "entity_ready_for_cataloging", entity: entity, to_roles: 'cataloger')
        repository.send_notification(
          notification: "confirmation_of_entity_approved_for_ingest", entity: entity,
          to_roles: ['creating_user', 'advisor', 'etd_reviewer'], additional_emails: additional_emails
        )
      end

      def after_trigger_finish_cataloging(_options)
        repository.submit_etd_student_submission_trigger!(entity: entity, trigger: :finish, user: user)
      end

      def build_state_machine
        state_machine = MicroMachine.new(entity.processing_state)
        state_machine.when(:submit_for_review, new: :under_review)
        state_machine.when(:request_revisions, under_review: :under_review)
        state_machine.when(:approve_for_ingest, under_review: :ready_for_ingest)
        state_machine.when(:ingest, ready_for_ingest: :ingested)
        state_machine.when(:ingest_completed, ingested: :ready_for_cataloging)
        state_machine.when(:finish_cataloging, ready_for_cataloging: :cataloged)
        state_machine.when(:finish, cataloged: :done)
        state_machine
      end

      # REVIEW: Will this be the convention? In other locations I'm using the
      # Runner.
      def convert_to_logged_name(event_name)
        "#{self.class.to_s.demodulize.underscore}/#{event_name}"
      end

      # REVIEW: Given that I need a repository, should this be teased into a
      # runner.
      def default_repository
        Repository.new
      end
    end
  end
end
