class AddAdditionalCollaboratorAttributes < ActiveRecord::Migration[4.2]
  def change
    # I'm opting to call it netid instead of net_id so as to not imply
    # this is a foreign key
    add_column :sipity_collaborators, :netid, :string
    add_column :sipity_collaborators, :email, :string
    add_column :sipity_collaborators, :responsible_for_review, :boolean, default: false

    add_index :sipity_collaborators, :netid
    add_index :sipity_collaborators, :email
  end
end
