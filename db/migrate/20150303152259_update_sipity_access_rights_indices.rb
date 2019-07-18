class UpdateSipityAccessRightsIndices < ActiveRecord::Migration[4.2]
  def change
    remove_index :sipity_access_rights, [:entity_id, :entity_type]
    add_index :sipity_access_rights, [:entity_id, :entity_type]
  end
end
