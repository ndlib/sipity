class RenameControlledVocabularyColumns < ActiveRecord::Migration[4.2]
  def change
    rename_column :sipity_simple_controlled_vocabularies, :predicate_value, :term_label
    rename_column :sipity_simple_controlled_vocabularies, :predicate_value_code, :term_uri
    remove_index :sipity_simple_controlled_vocabularies, name: 'sipity_simple_controlled_vocabularies_predicate_code'
    add_index :sipity_simple_controlled_vocabularies, :term_uri, name: 'sipity_simple_controlled_vocabularies_term_uri', unique: true
  end
end
