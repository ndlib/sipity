module Sipity
  module Services
    # The entry point into the notification (via email) subsystem.
    module Notifier
      module_function

      # @api public
      #
      # Providing a singular end point for sending messages
      #
      # @param entity The primary context for which we are delivering a notification
      # @param notification [String] The name of the notification we are attempting to send
      # @param email_service_finder [#call] Responsible for finding the mailer class for delivery
      def deliver(entity:, notification:, email_service_finder: default_email_service_finder, **options)
        notificaton_container = email_service_finder.call(entity: entity, notification: notification)
        deliver_email(notificaton_container: notificaton_container, notification: notification, options: options, entity: entity)
      end

      def default_email_service_finder
        Sipity::Mailers.method(:find_mailer_for)
      end
      private_class_method :default_email_service_finder

      def deliver_email(notificaton_container:, notification:, entity:, options:)
        to, cc, bcc = options.fetch(:to), options.fetch(:cc, []), options.fetch(:bcc, [])
        return notify_aibrake_of_no_sender if to.empty?
        email_notifier = notificaton_container.public_send(notification, entity: entity, to: to, cc: cc, bcc: bcc)
        email_notifier.deliver_now
      end
      private_class_method :deliver_email

      def notify_aibrake_of_no_sender
        Raven.capture_exception("#{Exceptions::SenderNotFoundError}: Return without sending message.")
        false
      end
      private_class_method :notify_aibrake_of_no_sender

      class << self
        alias call deliver
      end
    end
  end
end
