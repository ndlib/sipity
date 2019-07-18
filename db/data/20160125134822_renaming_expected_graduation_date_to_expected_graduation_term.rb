class RenamingExpectedGraduationDateToExpectedGraduationTerm < ActiveRecord::Migration[4.2]
  def self.up
    Sipity::Models::AdditionalAttribute.where(key: "expected_graduation_date").update_all(key: "expected_graduation_term")
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
