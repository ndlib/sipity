class CreateSipityModelsProcessingAdministrativeScheduledActions < ActiveRecord::Migration
  def change
    create_table :sipity_models_processing_administrative_scheduled_actions do |t|
      t.string :scheduled_time, null: false
      t.string :reason, null: false
      t.string :entity_id, null: false
      t.timestamps null: false
    end
  end
end
