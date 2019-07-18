class UpdateProcessingEntitiesColumnType < ActiveRecord::Migration[4.2]
  def change
    change_column(:sipity_processing_entities, :strategy_state_id, :integer)
  end
end
