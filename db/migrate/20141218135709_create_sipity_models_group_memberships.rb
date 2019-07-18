class CreateSipityModelsGroupMemberships < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_group_memberships do |t|
      t.integer :user_id
      t.integer :group_id
      t.string :membership_role

      t.timestamps
    end

    add_index :sipity_group_memberships, :user_id
    add_index :sipity_group_memberships, :group_id
    add_index :sipity_group_memberships, [:group_id, :membership_role]
    add_index :sipity_group_memberships, [:group_id, :user_id], unique: true

    change_column_null :sipity_group_memberships, :user_id, false
    change_column_null :sipity_group_memberships, :group_id, false
    change_column_null :sipity_group_memberships, :membership_role, false
  end
end
