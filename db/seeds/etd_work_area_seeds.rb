# This method is a hold-out to the one transaction per request of SQLLite
# I'd prefer to leverage find_or_create_by! in most all cases.
def find_or_initialize_or_create!(attributes = {})
  context = attributes.fetch(:context)
  receiver = attributes.fetch(:receiver)
  method_name = context.persisted? ? :find_or_create_by! : :find_or_initialize_by
  receiver.send(method_name, attributes.except(:context, :receiver))
end

Sipity::Services::CreateWorkAreaService.call(name: 'Electronic Thesis and Dissertation', slug: 'etd')

['doctoral_dissertation', 'master_thesis'].each do |work_type_name|
  $stdout.puts "Creating #{work_type_name} State Machine"
  Sipity::Services::FindOrCreateWorkTypeService.call(name: work_type_name) do |work_type, etd_strategy, _initial_strategy_state|
    etd_strategy_roles = {}

    [
      'creating_user',
      'etd_reviewer',
      'advisor'
    ].each do |role_name|
      etd_strategy_roles[role_name] = find_or_initialize_or_create!(
        context: etd_strategy,
        receiver: etd_strategy.strategy_roles,
        role: Sipity::Models::Role.find_by!(name: role_name)
      )
    end

    etd_reviewer = etd_strategy_roles.fetch('etd_reviewer')

    find_or_initialize_or_create!(
      context: etd_reviewer,
      receiver: etd_reviewer.strategy_responsibilities,
      actor: Sipity::Conversions::ConvertToProcessingActor.call(Sipity::Models::Group.find_by!(name: GRADUATE_SCHOOL_REVIEWERS))
    )

    etd_states = {}
    [
      'new',
      'under_advisor_review',
      'advisor_changes_requested',
      'under_grad_school_review',
      'grad_school_changes_requested',
      'ready_for_ingest'
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
      { action_name: 'describe', seq: 1 },
      { action_name: 'collaborators', seq: 2 },
      { action_name: 'attach', seq: 3 },
      { action_name: 'defense_date', seq: 4 },
      { action_name: 'search_terms', seq: 5 },
      { action_name: 'degree', seq: 6 },
      { action_name: 'access_policy', seq: 7 },
      { action_name: 'submit_for_review', resulting_state_name: 'under_advisor_review', seq: 1, allow_repeat_within_current_state: false },
      { action_name: 'advisor_signoff', resulting_state_name: 'under_grad_school_review', seq: 1, allow_repeat_within_current_state: false },
      { action_name: 'signoff_on_behalf_of', resulting_state_name: 'under_grad_school_review', seq: 1, allow_repeat_within_current_state: false },
      { action_name: 'advisor_requests_change', resulting_state_name: 'advisor_changes_requested', seq: 2, allow_repeat_within_current_state: false },
      { action_name: 'request_change_on_behalf_of', resulting_state_name: 'advisor_changes_requested', seq: 3, allow_repeat_within_current_state: false },
      { action_name: 'respond_to_advisor_request', resulting_state_name: 'under_advisor_review', seq: 1, allow_repeat_within_current_state: false  },
      { action_name: 'respond_to_grad_school_request', resulting_state_name: 'under_grad_school_review', seq: 1, allow_repeat_within_current_state: false },
      { action_name: 'grad_school_requests_change', resulting_state_name: 'grad_school_changes_requested', seq: 2, allow_repeat_within_current_state: false },
      { action_name: 'grad_school_signoff', resulting_state_name: 'ready_for_ingest',seq: 1, allow_repeat_within_current_state: false }
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
        action.update(
          presentation_sequence: structure.fetch(:seq), resulting_strategy_state: resulting_state,
          action_type: action.default_action_type, allow_repeat_within_current_state: structure.fetch(:allow_repeat_within_current_state, true)
        )
      else
        action.presentation_sequence = structure.fetch(:seq)
        action.allow_repeat_within_current_state = structure.fetch(:allow_repeat_within_current_state, true)
        # Because the objects are being instantiated differently, I need to make
        # sure to capture the default action_type.
        action.action_type = action.default_action_type
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
      'submit_for_review' => ['describe', 'degree', 'attach', 'collaborators', 'access_policy']
    }

    if work_type_name == 'doctoral_dissertation'
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
        ['new', 'under_advisor_review', 'advisor_changes_requested', 'under_grad_school_review', 'grad_school_changes_requested', 'ready_for_ingest'],
        ['show'],
        ['creating_user', 'advisor', 'etd_reviewer'],
      ],[
        ['new', 'advisor_changes_requested'],
        ['defense_date','degree', 'access_policy', 'describe','search_terms', 'attach', 'collaborators'],
        ['creating_user', 'etd_reviewer']
      ],[
        ['new'],
        ['destroy'],
        ['creating_user', 'etd_reviewer']
      ],[
        ['under_advisor_review', 'advisor_changes_requested', 'under_grad_school_review', 'grad_school_changes_requested'],
        ['destroy'],
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
        ['etd_reviewer', 'advisor']
      ],[
        ['under_grad_school_review'],
        ['grad_school_requests_change', 'grad_school_signoff'],
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
  end

  # Define associated emails by a named thing
  [
    {
      named_container: Sipity::Models::Processing::StrategyAction,
      name: 'submit_for_review',
      emails: {
        confirmation_of_submit_for_review: { to: 'creating_user' },
        submit_for_review: { to: ['advisor', 'etd_reviewer'] }
      }
    },
    {
      named_container: Sipity::Models::Processing::StrategyAction,
      name: 'advisor_signoff',
      emails: {
        advisor_signoff_is_complete: { to: 'etd_reviewer', cc: 'creating_user' },
        confirmation_of_advisor_signoff_is_complete: { to: 'creating_user' },
      }
    },
    {
      named_container: Sipity::Models::Processing::StrategyAction,
      name: 'signoff_on_behalf_of',
      emails: {
        advisor_signoff_is_complete: { to: 'etd_reviewer', cc: 'creating_user' },
        confirmation_of_advisor_signoff_is_complete: { to: 'creating_user' },
      }
    },
    {
      named_container: Sipity::Models::Processing::StrategyAction,
      name: 'advisor_requests_change',
      emails: {
        advisor_requests_change: { to: 'creating_user' }
      }
    },
    {
      named_container: Sipity::Models::Processing::StrategyAction,
      name: 'request_change_on_behalf_of',
      emails: {
        request_change_on_behalf_of: { to: 'creating_user' }
      }
    },
    {
      named_container: Sipity::Models::Processing::StrategyAction,
      name: 'respond_to_advisor_request',
      emails: { respond_to_advisor_request: { to: 'advisor', cc: 'creating_user'} }
    },
    {
      named_container: Sipity::Models::Processing::StrategyAction,
      name: 'respond_to_grad_school_request',
      emails: { respond_to_grad_school_request: { to: 'etd_reviewer', cc: 'creating_user'} }
    },
    {
      named_container: Sipity::Models::Processing::StrategyAction,
      name: 'grad_school_requests_change',
      emails: { grad_school_requests_change: { to: 'creating_user' } }
    },
    {
      named_container: Sipity::Models::Processing::StrategyAction,
      name: 'grad_school_signoff',
      emails: { confirmation_of_grad_school_signoff: { to: ['creating_user', 'etd_reviewer'] } }
    },
    {
      named_container: Sipity::Models::Processing::StrategyState,
      name: 'under_grad_school_review',
      emails: {
        advisor_signoff_is_complete: { to: 'etd_reviewer', cc: 'creating_user' },
        confirmation_of_advisor_signoff_is_complete: { to: 'creating_user' }
      }
    },
    {
      named_container: Sipity::Models::Processing::StrategyState,
      name: 'ready_for_ingest',
      emails: {
        advisor_signoff_is_complete: { to: 'etd_reviewer', cc: 'creating_user' },
        confirmation_of_advisor_signoff_is_complete: { to: 'creating_user' }
      }
    }
  ].each do |email_config|
    named_container = email_config.fetch(:named_container)
    name = email_config.fetch(:name)
    named_container.where(name: name).each do |named_thing|
      email_config.fetch(:emails).each do |email_name, recipients|
        the_email = Sipity::Models::Notification::Email.find_or_create_by!(method_name: email_name) do |email|
          recipients.slice(:to, :cc, :bcc).each do |(recipient_strategy, recipient_roles)|
            Array.wrap(recipient_roles).each do |recipient_role|
              find_or_initialize_or_create!(
                context: email,
                receiver: email.recipients,
                role: Sipity::Models::Role.find_by!(name: recipient_role),
                recipient_strategy: recipient_strategy.to_s
              )
            end
          end
        end
        reason_for_notification = begin
          case named_thing
          when Sipity::Models::Processing::StrategyAction
            Sipity::Parameters::NotificationContextParameter::REASON_ACTION_IS_TAKEN
          when Sipity::Models::Processing::StrategyState
            Sipity::Parameters::NotificationContextParameter::REASON_ENTERED_STATE
          end
        end
        Sipity::Models::Notification::NotifiableContext.find_or_create_by!(
          scope_for_notification: named_thing,
          reason_for_notification: reason_for_notification,
          email: the_email
        )
      end
    end
  end
end
