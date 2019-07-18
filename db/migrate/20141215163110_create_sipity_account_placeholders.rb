class CreateSipityAccountPlaceholders < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_account_placeholders do |t|
      t.string :identifier
      t.string :name
      t.string :identifier_type, limit: 32
      t.string :state, limit: 32, default: 'created'

      t.timestamps
    end
    add_index :sipity_account_placeholders, :identifier
    add_index :sipity_account_placeholders, [:identifier, :identifier_type], unique: true, name: 'sipity_account_placeholders_id_and_type'
    add_index :sipity_account_placeholders, :name
    add_index :sipity_account_placeholders, :state

    change_column_null :sipity_account_placeholders, :identifier, false
    change_column_null :sipity_account_placeholders, :identifier_type, false
    change_column_null :sipity_account_placeholders, :state, false
  end
end
