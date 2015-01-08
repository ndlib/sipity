module Sipity
  module Services
    # The entry point into the notification (via email) subsystem.
    class Notifier
      # Providing a singular end point for sending messages
      def self.deliver(options = {})
        notification_name = options.fetch(:notification)
        notificaton_container = options.fetch(:nonotificaton_container) { Sipity::Mailers::EmailNotifier }
        unless notificaton_container.respond_to?(notification_name)
          fail Exceptions::NotificationNotFoundError, name: notification_name, container: notificaton_container
        end
        to = options.fetch(:to)
        cc, bcc = options.fetch(:cc) { [] }, options.fetch(:bcc) { [] }
        entity = options.fetch(:entity)
        email_notifier = notificaton_container.public_send(notification_name, entity: entity, to: to, cc: cc, bcc: bcc)
        email_notifier.deliver_now
      end
    end
  end
end
