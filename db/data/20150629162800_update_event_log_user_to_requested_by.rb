class UpdateEventLogUserToRequestedBy < ActiveRecord::Migration[4.2]
  def self.up
    Sipity::Models::EventLog.where(requested_by_id: nil, requested_by_type: nil).find_each do |event_log|
      event_log.update!(requested_by_id: event_log.user_id, requested_by_type: User)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
