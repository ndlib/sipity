class CreateSipityModelsProcessingEntityActionRegister < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_processing_entity_action_registers do |t|
      t.integer :strategy_action_id, null: false
      t.string :entity_id, limit: 32, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_entity_action_registers, [:strategy_action_id, :entity_id],
      name: :sipity_processing_entity_action_registers_aggregate
  end
end
