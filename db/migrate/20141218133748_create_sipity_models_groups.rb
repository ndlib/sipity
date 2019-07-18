class CreateSipityModelsGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_groups do |t|
      t.string :name
      t.timestamps
    end
    add_index :sipity_groups, :name, unique: true
    change_column_null :sipity_groups, :name, false
  end
end
