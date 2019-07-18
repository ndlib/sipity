class CreateSipityModelsNotificationEmailRecipients < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_notification_email_recipients do |t|
      t.integer :email_id, null: false
      t.integer :role_id, null: false
      t.string :recipient_strategy, null: false

      t.timestamps null: false
    end

    add_index(
      :sipity_notification_email_recipients,
      :email_id,
      name: 'sipity_notification_email_recipients_email'
    )
    add_index(
      :sipity_notification_email_recipients,
      :role_id,
      name: 'sipity_notification_email_recipients_role'
    )
    add_index(
      :sipity_notification_email_recipients,
      :recipient_strategy,
      name: 'sipity_notification_email_recipients_recipient_strategy'
    )
    add_index(
      :sipity_notification_email_recipients,
      [:email_id, :role_id, :recipient_strategy],
      name: 'sipity_notification_email_recipients_surrogate'
    )

  end
end
