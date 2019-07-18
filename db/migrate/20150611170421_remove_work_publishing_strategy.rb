class RemoveWorkPublishingStrategy < ActiveRecord::Migration[4.2]
  def change
    remove_column 'sipity_works', 'work_publication_strategy'
  end
end
