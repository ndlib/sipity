class AddRepresentativeToAttachment < ActiveRecord::Migration[4.2]
  def change
    add_column :sipity_attachments, :is_representative_file, :boolean, default: false
  end
end
