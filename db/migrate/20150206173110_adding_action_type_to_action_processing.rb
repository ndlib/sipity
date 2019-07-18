class AddingActionTypeToActionProcessing < ActiveRecord::Migration[4.2]
  def change
    add_column :sipity_processing_strategy_actions, :action_type, :string, default: 'task'
    add_index :sipity_processing_strategy_actions, :action_type
    change_column_null :sipity_processing_strategy_actions, :action_type, false
  end
end
