class AddOpenDateAndClosedDateToSubmissionWindow < ActiveRecord::Migration[4.2]
  def change
    add_column :sipity_submission_windows, :open_for_starting_submissions_at, :datetime
    add_column :sipity_submission_windows, :closed_for_starting_submissions_at, :datetime
    add_index :sipity_submission_windows, :open_for_starting_submissions_at, name: :idx_submission_window_opening_at
    add_index :sipity_submission_windows, [:work_area_id, :open_for_starting_submissions_at], name: :idx_submission_windows_open_surrogate
    add_index :sipity_submission_windows, :closed_for_starting_submissions_at, name: :idx_submission_windows_closed_surrogate
  end
end
