class CreateSipityModelsProcessingAdministrativeScheduledAction < ActiveRecord::Migration
  def change
    create_table :sipity_models_processing_administrative_scheduled_action do |t|
      t.string :scheduled_time, null: false
      t.string :reason
      t.string :entity_id
      t.timestamps null: false
    end
  end
end
