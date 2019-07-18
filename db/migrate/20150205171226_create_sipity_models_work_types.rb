class CreateSipityModelsWorkTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_work_types do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps null: false
    end

    add_index :sipity_work_types, :name, unique: true
  end
end
