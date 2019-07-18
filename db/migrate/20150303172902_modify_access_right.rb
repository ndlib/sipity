class ModifyAccessRight < ActiveRecord::Migration[4.2]
  def change
    drop_table :sipity_access_rights

    create_table :sipity_access_rights do |t|
      t.string :entity_id, limit: 32
      t.string :entity_type
      t.string :access_right_code
      t.date :transition_date

      t.timestamps null: false
    end

    add_index :sipity_access_rights, [:entity_id, :entity_type], unique: true
    change_column_null :sipity_access_rights, :entity_id, false
    change_column_null :sipity_access_rights, :entity_type, false
    change_column_null :sipity_access_rights, :access_right_code, false
  end
end
