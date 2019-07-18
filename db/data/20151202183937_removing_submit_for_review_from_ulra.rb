class RemovingSubmitForReviewFromUlra < ActiveRecord::Migration[4.2]
  def self.up
    work_type = Sipity::Models::WorkType[Sipity::Models::WorkType::ULRA_SUBMISSION]
    strategy = work_type.strategy_usage.strategy
    submit_for_review_action = strategy.strategy_actions.find_by!(name: 'submit_for_review')
    submit_for_review_action.strategy_state_actions.includes(:originating_strategy_state).each do |state_actions|
      next unless state_actions.originating_strategy_state.name == 'new'
      state_actions.destroy
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
