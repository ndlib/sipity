class AddDefaultPresentationSequenceToControlledVocabularies < ActiveRecord::Migration[4.2]
  def change
    add_column 'sipity_simple_controlled_vocabularies', 'default_presentation_sequence', :integer

    add_index(
      "sipity_simple_controlled_vocabularies",
      ["predicate_name", 'default_presentation_sequence', "term_label"],
      name: "index_sipity_simple_controlled_vocabularies_order"
    )
  end
end
