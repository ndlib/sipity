class AddRequestorToEventLogs < ActiveRecord::Migration[4.2]
  def change
    add_column 'sipity_event_logs', 'requested_by_id', 'integer'
    add_column 'sipity_event_logs', 'requested_by_type', 'string'

    # As I am adding this column to production data, I cannot add the desired
    # NOT NULL database constraint. This is something that will need to come
    # along after the deploy and data migration.
    #
    # `change_column_null :sipity_event_logs, :requested_by_id, false`
    # `change_column_null :sipity_event_logs, :requested_by_type, false`
    add_index 'sipity_event_logs', ['requested_by_type', 'requested_by_id'], name: 'idx_sipity_event_logs_on_requested_by'
  end
end
