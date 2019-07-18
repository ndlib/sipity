class AddingColumnToControlledVocabulary < ActiveRecord::Migration[4.2]
  def change
    add_column :sipity_simple_controlled_vocabularies, :predicate_value_code, :string
    add_index :sipity_simple_controlled_vocabularies, :predicate_value_code, name: 'sipity_simple_controlled_vocabularies_predicate_code'
  end
end
