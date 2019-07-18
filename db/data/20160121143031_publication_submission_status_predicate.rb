class PublicationSubmissionStatusPredicate < ActiveRecord::Migration[4.2]
  def self.up
    Sipity::Models::AdditionalAttribute.
      where(key: 'submission_accepted_for_publication').
      update_all(key: 'publication_status_of_submission')
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
