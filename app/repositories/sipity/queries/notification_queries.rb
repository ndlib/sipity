module Sipity
  module Queries
    # Responsible for querying the notifications.
    module NotificationQueries
      def email_notifications_for(reason:, scope:)
        emails = Models::Notification::Email.arel_table
        notifiable_contexts = Models::Notification::NotifiableContext.arel_table
        Models::Notification::Email.where(
          emails[:id].in(
            notifiable_contexts.project(notifiable_contexts[:email_id]).where(
              notifiable_contexts[:scope_for_notification_id].eq(scope.id).and(
                notifiable_contexts[:scope_for_notification_type].eq(PowerConverter.convert(scope, to: :polymorphic_type))
              ).and(
                notifiable_contexts[:reason_for_notification].eq(reason)
              )
            )
          )
        ).includes(:recipients)
      end
    end
  end
end
