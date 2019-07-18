class CreateSipityModelsProcessingStrategyActionAnalogues < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_processing_strategy_action_analogues, force: true do |t|
      t.integer :strategy_action_id, null: false
      t.integer :analogous_to_strategy_action_id, null: false

      t.timestamps null: false
    end

    add_index(
      :sipity_processing_strategy_action_analogues,
      [:strategy_action_id, :analogous_to_strategy_action_id],
      unique: true,
      name: 'ix_sipity_processing_strategy_action_analogues_aggregate'
    )
    add_index(
      :sipity_processing_strategy_action_analogues,
      [:strategy_action_id],
      name: 'ix_sipity_processing_strategy_action_analogues_strategy'
    )
    add_index(
      :sipity_processing_strategy_action_analogues,
      [:analogous_to_strategy_action_id],
      name: 'ix_sipity_processing_strategy_action_analogues_analogous_stgy'
    )
  end
end
