class CreateSipityModelsProcessingStrategyUsages < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_processing_strategy_usages do |t|
      t.integer :strategy_id, null: false
      t.integer :usage_id, null: false
      t.string :usage_type, null: false

      t.timestamps null: false
    end

    add_index(
      :sipity_processing_strategy_usages,
      [:usage_id, :usage_type],
      name: 'idx_sipity_processing_strategy_usages_usage_fk',
      unique: true
    )
    add_index(
      :sipity_processing_strategy_usages,
      :strategy_id,
      name: 'idx_sipity_processing_strategy_usages_strategy_fk'
    )
  end
end
