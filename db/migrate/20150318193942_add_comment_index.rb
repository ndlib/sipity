class AddCommentIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :sipity_processing_comments, :created_at
  end
end
