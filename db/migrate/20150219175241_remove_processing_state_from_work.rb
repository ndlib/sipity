class RemoveProcessingStateFromWork < ActiveRecord::Migration[4.2]
  def change
    remove_column :sipity_works, :processing_state
  end
end
