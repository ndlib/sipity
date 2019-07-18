class CreateSipityModelsApplicationConcepts < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_application_concepts do |t|
      t.string :name, null: false, unique: true
      t.string :class_name, null: false
      t.string :slug, null: false

      t.timestamps null: false
    end
  end
end
