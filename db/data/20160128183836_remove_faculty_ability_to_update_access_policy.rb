class RemoveFacultyAbilityToUpdateAccessPolicy < ActiveRecord::Migration[4.2]
  def self.up
    advising_role = Sipity::Models::Role['advising']
    advising_role.processing_strategy_roles.find_each do |strategy_role|
      strategy_role.strategy_state_action_permissions.find_each do |state_action_permission|
        case state_action_permission.strategy_state_action.strategy_action.name
        when 'access_policy'
          state_action_permission.destroy
        when 'faculty_response'
          next unless state_action_permission.strategy_state_action.originating_strategy_state.name == 'pending_student_completion'
          state_action_permission.strategy_state_action.destroy
        end
      end
    end
    submit_advisor_portion = Sipity::Models::Processing::StrategyAction.find_by!(name: 'submit_advisor_portion')
    Sipity::Models::Processing::StrategyActionPrerequisite.where(guarded_strategy_action: submit_advisor_portion).each do |action_prerequisite|
      next unless action_prerequisite.prerequisite_strategy_action.name == 'access_policy'
      action_prerequisite.destroy
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
