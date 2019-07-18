class CreateSipityModelsProcessingAdministrativeScheduledActions < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_models_processing_administrative_scheduled_actions do |t|
      t.datetime :scheduled_time, null: false
      t.string :reason, null: false
      t.string :entity_id, null: false
      t.timestamps null: false
    end
    add_index :sipity_models_processing_administrative_scheduled_actions, [:entity_id, :reason], name: :idx_sipity_scheduled_actions_entity_id_reason
  end
end
