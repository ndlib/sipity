class CreateSipityEventLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_event_logs do |t|
      t.integer :user_id, index: true
      t.string :entity_id, limit: 32
      t.string :entity_type, limit: 64
      t.string :event_name, index: true

      t.timestamps
    end

    add_index :sipity_event_logs, [:user_id, :entity_id, :entity_type], name: :sipity_event_logs_user_subject
    add_index :sipity_event_logs, [:entity_id, :entity_type, :event_name], name: :sipity_event_logs_entity_action_name
    add_index :sipity_event_logs, [:entity_id, :entity_type], name: :sipity_event_logs_subject
    add_index :sipity_event_logs, [:user_id, :event_name], name: :sipity_event_logs_user_event_name

    change_column_null :sipity_event_logs, :user_id, false
    change_column_null :sipity_event_logs, :entity_id, false
    change_column_null :sipity_event_logs, :entity_type, false
    change_column_null :sipity_event_logs, :event_name, false
  end
end
