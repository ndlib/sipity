class AddingPrimaryKeyToWorkSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :sipity_work_submissions, :id, :primary_key
  end
end
