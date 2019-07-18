class AddingColumnConstraintToAttachment < ActiveRecord::Migration[4.2]
  def change
    change_column_null :sipity_attachments, :pid, false
  end
end
