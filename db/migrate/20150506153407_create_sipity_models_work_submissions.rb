class CreateSipityModelsWorkSubmissions < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_work_submissions, id: false do |t|
      t.integer :work_area_id, null: false
      t.integer :submission_window_id, null: false
      t.string :work_id, null: false

      t.timestamps null: false
    end

    add_index :sipity_work_submissions, [:work_area_id, :work_id], name: :idx_sipity_work_submissions_work_area
    add_index :sipity_work_submissions, [:submission_window_id, :work_id], name: :idx_sipity_work_submissions_submission_window
    add_index :sipity_work_submissions, [:work_id], unique: true, name: :idx_sipity_work_submissions_primary_key
  end
end
