class CreateSipityModelsSubmissionWindows < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_submission_windows do |t|
      t.integer :work_area_id, null: false, index: true
      t.string :slug, null: false, index: true

      t.timestamps null: false
    end
    add_index :sipity_submission_windows, [:work_area_id, :slug], unique: true
  end
end
