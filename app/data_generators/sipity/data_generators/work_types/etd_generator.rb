module Sipity
  module DataGenerators
    module WorkTypes
      # Responsible for generating the work types within the ETD.
      class EtdGenerator
        WORK_TYPE_NAMES = [
          Models::WorkType::DOCTORAL_DISSERTATION,
          Models::WorkType::MASTER_THESIS
        ]
        PROCESSING_ROLE_NAMES = [
          Models::Role::CREATING_USER,
          Models::Role::ETD_REVIEWER,
          Models::Role::ADVISOR
        ]
        GRADUATE_SCHOOL_REVIEWERS = 'Graduate School Reviewers'
        CATALOGERS = "Catalogers"

        def self.call(**keywords)
          new(**keywords).call
        end

        def initialize(work_area:, submission_window:, **keywords)
          self.submission_window = submission_window
          self.work_area = work_area
        end

        private

        attr_accessor :submission_window, :work_area

        public

        def call
          associate_work_types_and_their_state_machines_with_submission_window!
        end

        private
        # The goal is to create an idempotent script
        def find_or_initialize_or_create!(context:, receiver:, **attributes)
          method_name = context.persisted? ? :find_or_create_by! : :find_or_initialize_by
          receiver.send(method_name, attributes)
        end

        def associate_work_types_and_their_state_machines_with_submission_window!
          WORK_TYPE_NAMES.each do |work_type_name|
            DataGenerators::FindOrCreateWorkType.call(name: work_type_name) do |work_type, etd_strategy, initial_state|
              Models::SubmissionWindowWorkType.find_or_create_by!(work_type: work_type, submission_window: submission_window)

              etd_strategy_roles = {}

              [
                'creating_user',
                'etd_reviewer',
                'advisor',
                'cataloger'
              ].each do |role_name|
                etd_strategy_roles[role_name] = find_or_initialize_or_create!(
                  context: etd_strategy,
                  receiver: etd_strategy.strategy_roles,
                  role: Models::Role.find_or_create_by!(name: role_name)
                )
              end

              etd_reviewer = etd_strategy_roles.fetch('etd_reviewer')
              cataloger = etd_strategy_roles.fetch('cataloger')

              find_or_initialize_or_create!(
                context: etd_reviewer,
                receiver: etd_reviewer.strategy_responsibilities,
                actor: Conversions::ConvertToProcessingActor.call(Models::Group.find_or_create_by!(name: GRADUATE_SCHOOL_REVIEWERS))
              )

              find_or_initialize_or_create!(
                context: cataloger,
                receiver: cataloger.strategy_responsibilities,
                actor: Conversions::ConvertToProcessingActor.call(Models::Group.find_or_create_by!(name: CATALOGERS))
              )

              etd_states = {}
              [
                'new',
                'under_advisor_review',
                'advisor_changes_requested',
                'under_grad_school_review',
                'grad_school_changes_requested',
                'ready_for_ingest',
                'ready_for_cataloging',
                'back_from_cataloging'
              ].each do |state_name|
                etd_states[state_name] = find_or_initialize_or_create!(
                  context: etd_strategy,
                  receiver: etd_strategy.strategy_states,
                  name: state_name
                )
              end

              etd_actions = {}
              [
                { action_name: 'show', seq: 1 },
                { action_name: 'destroy', seq: 2 },
                { action_name: 'debug', seq: 3 },
                { action_name: 'start_a_submission', seq: 0, resulting_state_name: 'new', allow_repeat_within_current_state: false }, # A bit of a misnomer
                { action_name: 'publishing_and_patenting_intent', seq: 1 },
                { action_name: 'describe', seq: 2 },
                { action_name: 'collaborators', seq: 3 },
                { action_name: 'attach', seq: 4 },
                { action_name: 'defense_date', seq: 5 },
                { action_name: 'search_terms', seq: 6 },
                { action_name: 'degree', seq: 7 },
                { action_name: 'access_policy', seq: 8 },
                { action_name: 'submit_for_review', resulting_state_name: 'under_advisor_review', seq: 1, allow_repeat_within_current_state: false },
                { action_name: 'advisor_signoff', resulting_state_name: 'under_grad_school_review', seq: 1, allow_repeat_within_current_state: false },
                { action_name: 'signoff_on_behalf_of', resulting_state_name: 'under_grad_school_review', seq: 1, allow_repeat_within_current_state: true },
                { action_name: 'advisor_requests_change', resulting_state_name: 'advisor_changes_requested', seq: 2, allow_repeat_within_current_state: false },
                { action_name: 'request_change_on_behalf_of', resulting_state_name: 'advisor_changes_requested', seq: 3, allow_repeat_within_current_state: false },
                { action_name: 'respond_to_advisor_request', resulting_state_name: 'under_advisor_review', seq: 1, allow_repeat_within_current_state: false  },
                { action_name: 'respond_to_grad_school_request', resulting_state_name: 'grad_school_changes_requested', seq: 1, allow_repeat_within_current_state: true },
                { action_name: 'grad_school_requests_change', resulting_state_name: 'grad_school_changes_requested', seq: 2, allow_repeat_within_current_state: true },
                { action_name: 'send_to_cataloging', resulting_state_name: 'ready_for_cataloging',seq: 1, allow_repeat_within_current_state: false },
                { action_name: 'send_back_to_grad_school', resulting_state_name: 'back_from_cataloging',seq: 2, allow_repeat_within_current_state: true },
                { action_name: 'cataloging_complete', resulting_state_name: 'ready_for_ingest',seq: 1, allow_repeat_within_current_state: false },
                { action_name: 'ingest_with_postponed_cataloging', resulting_state_name: 'ready_for_ingest',seq: 1, allow_repeat_within_current_state: false }
              ].each do |structure|
                action_name = structure.fetch(:action_name)
                resulting_state = structure[:resulting_state_name] ? etd_states.fetch(structure[:resulting_state_name]) : nil
                action = find_or_initialize_or_create!(
                  context: etd_strategy,
                  receiver: etd_strategy.strategy_actions,
                  name: action_name
                )

                # Because the objects are being instantiated differently, I need to make
                # sure to capture the default action_type.
                action.resulting_strategy_state = resulting_state
                if action.persisted?
                  expected_attributes = {
                    presentation_sequence: structure.fetch(:seq),
                    action_type: action.default_action_type,
                    allow_repeat_within_current_state: structure.fetch(:allow_repeat_within_current_state, true)
                  }
                  # No sense making changes if none are needed
                  if expected_attributes.any? { |key, value| action.attributes[key.to_s] != value }
                    action.update(
                      presentation_sequence: structure.fetch(:seq), resulting_strategy_state: resulting_state,
                      action_type: action.default_action_type, allow_repeat_within_current_state: structure.fetch(:allow_repeat_within_current_state, true)
                    )
                  end
                end
                etd_actions[action_name] = action
              end

              [
                { action: 'advisor_requests_change', analogous_to: 'advisor_signoff' }
              ].each do |options|
                action = etd_actions.fetch(options.fetch(:action))
                analogous_to = etd_actions.fetch(options.fetch(:analogous_to))
                find_or_initialize_or_create!(
                  context: action,
                  receiver: action.base_element_for_strategy_actions_analogues,
                  analogous_to_strategy_action: analogous_to
                )
              end

              pre_requisite_states =       {
                'submit_for_review' => ['describe', 'degree', 'attach', 'collaborators', 'access_policy', 'publishing_and_patenting_intent']
              }

              if work_type_name == Models::WorkType::DOCTORAL_DISSERTATION
                pre_requisite_states['submit_for_review'] << 'defense_date'
              end

              pre_requisite_states.each do |guarded_action_name, prereq_action_names|
                guarded_action = etd_actions.fetch(guarded_action_name)
                Array.wrap(prereq_action_names).each do |prereq_action_name|
                  prereq_action = etd_actions.fetch(prereq_action_name)
                  find_or_initialize_or_create!(
                    context: guarded_action,
                    receiver: guarded_action.requiring_strategy_action_prerequisites,
                    prerequisite_strategy_action: prereq_action
                  )
                end
              end


              [
                [
                  ['new'],
                  ['submit_for_review'],
                  ['creating_user']
                ],[
                  ['advisor_changes_requested'],
                  ['respond_to_advisor_request'],
                  ['creating_user']
                ],[
                  ['grad_school_changes_requested'],
                  ['respond_to_grad_school_request'],
                  ['creating_user']
                ],[
                  ['new', 'under_advisor_review', 'advisor_changes_requested', 'under_grad_school_review', 'grad_school_changes_requested', 'ready_for_cataloging', 'back_from_cataloging', 'ready_for_ingest'],
                  ['show'],
                  ['creating_user', 'advisor', 'etd_reviewer'],
                ],[
                  ['new', 'advisor_changes_requested'],
                  ['defense_date','degree', 'access_policy', 'publishing_and_patenting_intent', 'describe','search_terms', 'attach', 'collaborators'],
                  ['creating_user', 'etd_reviewer']
                ],[
                  ['grad_school_changes_requested', 'under_grad_school_review'],
                  ['defense_date','degree', 'access_policy', 'publishing_and_patenting_intent', 'describe','search_terms', 'attach', 'collaborators'],
                  ['etd_reviewer']
                ],[
                  ['new'],
                  ['destroy'],
                  ['creating_user', 'etd_reviewer']
                ],[
                  ['under_advisor_review', 'advisor_changes_requested', 'under_grad_school_review', 'grad_school_changes_requested'],
                  ['destroy'],
                  ['etd_reviewer']
                ],[
                  ['new', 'under_advisor_review', 'advisor_changes_requested', 'under_grad_school_review', 'grad_school_changes_requested', 'ready_for_cataloging', 'back_from_cataloging', 'ready_for_ingest'],
                  ['debug'],
                  ['etd_reviewer']
                ],[
                  ['ready_for_cataloging'],
                  ['send_back_to_grad_school', 'cataloging_complete'],
                  ['cataloger']
                ],[
                  ['back_from_cataloging'],
                  ['send_to_cataloging', 'ingest_with_postponed_cataloging'],
                  ['etd_reviewer']
                ],[
                  ['under_advisor_review'],
                  ['advisor_signoff'],
                  ['advisor']
                ],[
                  ['under_advisor_review'],
                  ['signoff_on_behalf_of', 'request_change_on_behalf_of'],
                  ['etd_reviewer']
                ],[
                  ['under_advisor_review'],
                  ['advisor_requests_change'],
                  ['advisor']
                ],[
                  ['under_grad_school_review', 'grad_school_changes_requested'],
                  ['grad_school_requests_change', 'send_to_cataloging', 'ingest_with_postponed_cataloging'],
                  ['etd_reviewer']
                ]
              ].each do |originating_state_names, action_names, role_names|
                Array.wrap(originating_state_names).each do |originating_state_name|
                  Array.wrap(action_names).each do |action_name|
                    action = etd_actions.fetch(action_name)
                    originating_state = etd_states.fetch(originating_state_name)
                    event = find_or_initialize_or_create!(
                      context: action,
                      receiver: action.strategy_state_actions,
                      originating_strategy_state: originating_state
                    )

                    Array.wrap(role_names).each do |role_name|
                      strategy_role = etd_strategy_roles.fetch(role_name)
                      find_or_initialize_or_create!(
                        context: strategy_role,
                        receiver: strategy_role.strategy_state_action_permissions,
                        strategy_state_action: event
                      )
                    end
                  end
                end
              end

              # Define associated emails by a named thing
              [
                {
                  named_container: Models::Processing::StrategyAction,
                  name: 'start_a_submission',
                  emails: {
                    confirmation_of_work_created: { to: 'creating_user' }
                  }
                },
                {
                  named_container: Models::Processing::StrategyAction,
                  name: 'submit_for_review',
                  emails: {
                    confirmation_of_submit_for_review: { to: 'creating_user' },
                    submit_for_review: { to: ['advisor'] }
                  }
                },
                {
                  named_container: Models::Processing::StrategyAction,
                  name: 'advisor_signoff',
                  emails: {
                    confirmation_of_advisor_signoff: { to: 'creating_user' },
                  }
                },
                {
                  named_container: Models::Processing::StrategyAction,
                  name: 'signoff_on_behalf_of',
                  emails: {
                    confirmation_of_advisor_signoff: { to: 'creating_user' },
                  }
                },
                {
                  named_container: Models::Processing::StrategyAction,
                  name: 'advisor_requests_change',
                  emails: {
                    advisor_requests_change: { to: 'creating_user' }
                  }
                },
                {
                  named_container: Models::Processing::StrategyAction,
                  name: 'request_change_on_behalf_of',
                  emails: {
                    request_change_on_behalf_of: { to: 'creating_user' }
                  }
                },
                {
                  named_container: Models::Processing::StrategyAction,
                  name: 'respond_to_advisor_request',
                  emails: { respond_to_advisor_request: { to: 'advisor', cc: 'creating_user'} }
                },
                {
                  named_container: Models::Processing::StrategyAction,
                  name: 'respond_to_grad_school_request',
                  emails: { respond_to_grad_school_request: { to: 'etd_reviewer', cc: 'creating_user'} }
                },
                {
                  named_container: Models::Processing::StrategyAction,
                  name: 'grad_school_requests_change',
                  emails: { grad_school_requests_change: { to: 'creating_user' } }
                },
                {
                  named_container: Models::Processing::StrategyAction,
                  name: 'send_to_cataloging',
                  emails: { grad_school_requests_cataloging: { to: 'cataloger', cc: 'etd_reviewer' } }
                },
                {
                  named_container: Models::Processing::StrategyAction,
                  name: 'send_back_to_grad_school',
                  emails: { cataloger_request_change: { to: 'etd_reviewer' } }
                },
                {
                  named_container: Models::Processing::StrategyState,
                  name: 'under_grad_school_review',
                  emails: {
                    advisor_signoff_is_complete: { to: 'etd_reviewer', cc: 'creating_user' },
                    confirmation_of_advisor_signoff_is_complete: { to: 'creating_user' }
                  }
                }
              ].each do |email_config|
                named_container = email_config.fetch(:named_container)
                name = email_config.fetch(:name)
                named_container.where(name: name, strategy: etd_strategy).each do |named_thing|
                  email_config.fetch(:emails).each do |email_name, recipients|
                    the_email = Models::Notification::Email.find_or_create_by!(method_name: email_name) do |email|
                      recipients.slice(:to, :cc, :bcc).each do |(recipient_strategy, recipient_roles)|
                        Array.wrap(recipient_roles).each do |recipient_role|
                          find_or_initialize_or_create!(
                            context: email,
                            receiver: email.recipients,
                            role: Models::Role.find_by!(name: recipient_role),
                            recipient_strategy: recipient_strategy.to_s
                          )
                        end
                      end
                    end
                    reason_for_notification = begin
                      case named_thing
                      when Models::Processing::StrategyAction
                        Parameters::NotificationContextParameter::REASON_ACTION_IS_TAKEN
                      when Models::Processing::StrategyState
                        Parameters::NotificationContextParameter::REASON_ENTERED_STATE
                      end
                    end
                    Models::Notification::NotifiableContext.find_or_create_by!(
                      scope_for_notification: named_thing,
                      reason_for_notification: reason_for_notification,
                      email: the_email
                    )
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
