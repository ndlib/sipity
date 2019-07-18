class CreateSipityModelsWorkAreas < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_work_areas do |t|
      t.string :slug, null: false, unique: true
      t.string :partial_suffix, null: false
      t.string :demodulized_class_prefix_name, null: false
      t.timestamps null: false
    end
  end
end
