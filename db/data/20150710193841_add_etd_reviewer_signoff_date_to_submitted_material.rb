class AddEtdReviewerSignoffDateToSubmittedMaterial < ActiveRecord::Migration[4.2]
  def self.up
    def self.up
      repository = Sipity::CommandRepository.new
      previous_entity = nil
      Sipity::Models::EventLog.where(
        event_name: 'grad_school_signoff/submit', entity_type: Sipity::Models::Work
      ).order('entity_id, created_at DESC') do |event_log|
        entity = event_log.entity
        next if previous_entity == entity
        previous_entity = entity
        repository.update_work_attribute_values!(
          work: entity,
          values: event_log.created_at.strftime(Models::AdditionalAttribute::DATE_FORMAT),
          key: Models::AdditionalAttribute::ETD_REVIEWER_SIGNOFF_DATE
        )
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
