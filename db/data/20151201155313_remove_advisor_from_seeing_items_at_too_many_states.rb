class RemoveAdvisorFromSeeingItemsAtTooManyStates < ActiveRecord::Migration[4.2]
  # Removing permission for advisors to see the ETDs at far later states
  def self.up
    [
      Sipity::Models::WorkType[Sipity::Models::WorkType::DOCTORAL_DISSERTATION],
      Sipity::Models::WorkType[Sipity::Models::WorkType::MASTER_THESIS]
    ].each do |work_type|
      strategy = work_type.strategy_usage.strategy
      show_action = strategy.strategy_actions.find_by!(name: 'show')
      advisor_strategy_role = strategy.strategy_roles.includes(:role).to_a.detect { |a_strategy_role| a_strategy_role.role.name == 'advising' }
      raise "Could not find a advisor" unless advisor_strategy_role
      [
        'under_grad_school_review',
        'grad_school_changes_requested',
        'ready_for_cataloging',
        'grad_school_approved_but_waiting_for_routing',
        'back_from_cataloging',
        'ready_for_ingest',
        'ingesting',
        'ingested'
      ].each do |state_name|
        state = strategy.strategy_states.find_by!(name: state_name)
        state.originating_strategy_state_actions.includes(:strategy_action).each do |strategy_state_action|
          next unless strategy_state_action.strategy_action == show_action
          Sipity::Models::Processing::StrategyStateActionPermission.where(strategy_role: advisor_strategy_role, strategy_state_action: strategy_state_action).destroy_all
        end
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
