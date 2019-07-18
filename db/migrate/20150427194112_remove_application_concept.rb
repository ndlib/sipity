class RemoveApplicationConcept < ActiveRecord::Migration[4.2]
  def change
    drop_table :sipity_application_concepts
  end
end
