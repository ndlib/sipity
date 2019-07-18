class CreateSipityModelsSimpleControlledVocabularies < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_simple_controlled_vocabularies do |t|
      t.string :predicate_name
      t.string :predicate_value

      t.timestamps null: false
    end

    add_index :sipity_simple_controlled_vocabularies, :predicate_name
    add_index :sipity_simple_controlled_vocabularies, [:predicate_name, :predicate_value], unique: true, name: :index_sipity_simple_controlled_vocabularies_unique
    change_column_null :sipity_simple_controlled_vocabularies, :predicate_name, false
    change_column_null :sipity_simple_controlled_vocabularies, :predicate_value, false
  end
end
