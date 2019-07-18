class CreateSipityModelsAccessRights < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_access_rights do |t|
      t.string :entity_id, limit: 32
      t.string :entity_type
      t.string :access_right_code
      t.date :enforcement_start_date
      t.date :enforcement_end_date

      t.timestamps null: false
    end

    add_index :sipity_access_rights, [:entity_id, :entity_type], unique: true
    add_index(
      :sipity_access_rights, [:entity_id, :entity_type, :enforcement_start_date],
      unique: true, name: :sipity_access_rights_start_for_entity
    )
    add_index(
      :sipity_access_rights, [:entity_id, :entity_type, :enforcement_end_date],
      unique: true, name: :sipity_access_rights_end_for_entity
    )
    change_column_null :sipity_access_rights, :entity_id, false
    change_column_null :sipity_access_rights, :entity_type, false
    change_column_null :sipity_access_rights, :access_right_code, false
    change_column_null :sipity_access_rights, :enforcement_start_date, false
  end
end
