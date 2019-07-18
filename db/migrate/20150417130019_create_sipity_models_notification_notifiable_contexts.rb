class CreateSipityModelsNotificationNotifiableContexts < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_notification_notifiable_contexts do |t|
      t.integer :scope_for_notification_id, null: false
      t.string :scope_for_notification_type, null: false
      t.string :reason_for_notification, null: false
      t.integer :email_id, null: false

      t.timestamps null: false
    end
    add_index(
      :sipity_notification_notifiable_contexts,
      [:scope_for_notification_id, :scope_for_notification_type],
      name: :idx_sipity_notification_notifiable_contexts_concern
    )
    add_index(
      :sipity_notification_notifiable_contexts,
      [:scope_for_notification_id, :scope_for_notification_type, :reason_for_notification],
      name: :idx_sipity_notification_notifiable_contexts_concern_context
    )
    add_index(
      :sipity_notification_notifiable_contexts,
      [:email_id],
      name: :idx_sipity_notification_notifiable_contexts_email_id
    )
    add_index(
      :sipity_notification_notifiable_contexts,
      [:scope_for_notification_id, :scope_for_notification_type, :reason_for_notification, :email_id],
      name: :idx_sipity_notification_notifiable_contexts_concern_surrogate,
      unique: true
    )
  end
end
