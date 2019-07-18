class AddOpenDateToCurrentSubmissionWindows < ActiveRecord::Migration[4.2]
  def self.up
    # I'm sure there is a better date mechanism for this but its a quick fix
    Sipity::Models::SubmissionWindow.where(open_for_starting_submissions_at: nil).find_each do |submission_window|
      submission_window.update_column(:open_for_starting_submissions_at, submission_window.created_at)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
