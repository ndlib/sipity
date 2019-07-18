class CreateSipityModelsProcessingEntitySpecificResponsibility < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_processing_entity_specific_responsibilities do |t|
      t.integer :strategy_role_id, null: false
      t.string :entity_id, limit: 32, null: false
      t.integer :actor_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_entity_specific_responsibilities, [:strategy_role_id, :entity_id, :actor_id],
      unique: true, name: :sipity_processing_entity_specific_responsibilities_aggregate
    add_index :sipity_processing_entity_specific_responsibilities, :strategy_role_id,
      name: :sipity_processing_entity_specific_responsibilities_role
    add_index :sipity_processing_entity_specific_responsibilities, :entity_id,
      name: :sipity_processing_entity_specific_responsibilities_entity
    add_index :sipity_processing_entity_specific_responsibilities, :actor_id,
      name: :sipity_processing_entity_specific_responsibilities_actor
  end
end
