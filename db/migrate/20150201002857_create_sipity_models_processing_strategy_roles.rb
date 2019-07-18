class CreateSipityModelsProcessingStrategyRoles < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_processing_strategy_roles do |t|
      t.integer :strategy_id, null: false
      t.integer :role_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_processing_strategy_roles, [:strategy_id, :role_id], unique: true,
      name: :sipity_processing_strategy_roles_aggregate
  end
end
