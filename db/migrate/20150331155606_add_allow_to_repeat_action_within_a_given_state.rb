class AddAllowToRepeatActionWithinAGivenState < ActiveRecord::Migration[4.2]
  def change
    add_column :sipity_processing_strategy_actions, :allow_repeat_within_current_state, :boolean, default: true, null: false
  end
end
