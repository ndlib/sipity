class RemoveGradSchoolRequestsCatalogingForActionTaken < ActiveRecord::Migration[4.2]
  def self.up
    Sipity::Models::Notification::Email.where(method_name: 'grad_school_requests_cataloging').each do |email|
      email.notifiable_contexts.where(
        reason_for_notification: 'action_is_taken', scope_for_notification_type: 'Sipity::Models::Processing::StrategyAction'
      ).destroy_all
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
