class CreateSipPermissions < ActiveRecord::Migration
  def change
    create_table :sip_permissions do |t|
      t.integer :user_id, index: true
      t.integer :subject_id, index: true
      t.string :subject_type, index: true, limit: 32
      t.string :role, index: true, limit: 32

      t.timestamps
    end
    add_index :sip_permissions, [:user_id, :subject_id, :subject_type], name: :sip_permissions_user_subject
    add_index :sip_permissions, [:subject_id, :subject_type, :role], name: :sip_permissions_subject_role
    add_index :sip_permissions, [:user_id, :role], name: :sip_permissions_user_role

    change_column_null :sip_permissions, :user_id, false
    change_column_null :sip_permissions, :subject_id, false
    change_column_null :sip_permissions, :subject_type, false
    change_column_null :sip_permissions, :role, false
  end
end
