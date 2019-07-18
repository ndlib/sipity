class RemovingDefaultActionType < ActiveRecord::Migration[4.2]
  def change
    change_column_default :sipity_processing_strategy_actions, :action_type, nil
  end
end
