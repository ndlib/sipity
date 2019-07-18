class CreateSipityPermissions < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_permissions, id: false do |t|
      t.integer :actor_id, index: true
      t.string :actor_type, index: true, limit: 64
      t.string :acting_as, index: true, limit: 32
      t.string :entity_id, limit: 32, index: true
      t.string :entity_type, index: true, limit: 64

      t.timestamps
    end
    add_index :sipity_permissions, [:actor_id, :actor_type, :entity_id, :entity_type], name: :sipity_permissions_actor_subject
    add_index :sipity_permissions, [:entity_id, :entity_type, :acting_as], name: :sipity_permissions_entity_acting_as
    add_index :sipity_permissions, [:actor_id, :actor_type, :acting_as], name: :sipity_permissions_actor_acting_as

    change_column_null :sipity_permissions, :actor_id, false
    change_column_null :sipity_permissions, :actor_type, false
    change_column_null :sipity_permissions, :entity_id, false
    change_column_null :sipity_permissions, :entity_type, false
    change_column_null :sipity_permissions, :acting_as, false
  end
end
