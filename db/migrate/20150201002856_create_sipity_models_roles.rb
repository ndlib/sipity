class CreateSipityModelsRoles < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_roles do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps null: false
    end

    add_index :sipity_roles, :name, unique: true
  end
end
