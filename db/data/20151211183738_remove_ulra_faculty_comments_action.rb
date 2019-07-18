class RemoveUlraFacultyCommentsAction < ActiveRecord::Migration[4.2]
  def self.up
    # This works for now but may not work going forward.
    Sipity::Models::Processing::StrategyAction.where(name: 'faculty_comments').destroy_all
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
