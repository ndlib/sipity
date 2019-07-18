class AddingStaleToProcessingComment < ActiveRecord::Migration[4.2]
  def change
    add_column 'sipity_processing_comments', 'stale', :boolean, default: false, index: true
  end
end
