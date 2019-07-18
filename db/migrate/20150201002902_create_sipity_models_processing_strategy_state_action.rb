class CreateSipityModelsProcessingStrategyStateAction < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_processing_strategy_state_actions do |t|
      t.integer :originating_strategy_state_id, null: false
      t.integer :strategy_action_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_state_actions, [:originating_strategy_state_id, :strategy_action_id],
      unique: true, name: :sipity_processing_strategy_state_actions_aggregate
  end
end
