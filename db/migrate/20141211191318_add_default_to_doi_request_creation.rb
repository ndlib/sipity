class AddDefaultToDoiRequestCreation < ActiveRecord::Migration[4.2]
  def change
    # I'm using a magic string because I don't want to load the class and
    # create all kinds of load issues.
    change_column :sipity_doi_creation_requests, :state, :string, default: 'request_not_yet_submitted', null: false
    add_index :sipity_doi_creation_requests, :work_id, unique: true
    change_column_null :sipity_doi_creation_requests, :work_id, false
    remove_column :sipity_doi_creation_requests, :text
  end
end
