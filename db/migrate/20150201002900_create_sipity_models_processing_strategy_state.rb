class CreateSipityModelsProcessingStrategyState < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_processing_strategy_states do |t|
      t.integer :strategy_id, null: false
      t.string :name, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_states, [:strategy_id, :name],
      unique: true, name: :sipity_processing_type_state_aggregate
  end
end
