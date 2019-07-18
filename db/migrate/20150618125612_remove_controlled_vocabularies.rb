class RemoveControlledVocabularies < ActiveRecord::Migration[4.2]
  def change
    drop_table :sipity_simple_controlled_vocabularies
  end
end
