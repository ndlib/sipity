class RemovePermissionsTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :sipity_permissions
  end
end
