class AddIndicesToSipityAdditionalAttributes < ActiveRecord::Migration[4.2]
  def change
    add_index :sipity_additional_attributes, :work_id
    add_index :sipity_additional_attributes, [:work_id, :key]
  end
end
