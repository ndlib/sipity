class CreateSipityModelsProcessingStrategy < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_processing_strategies do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps null: false
    end

    add_index :sipity_processing_strategies, :name, unique: true
  end
end
