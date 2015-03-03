module Sipity
  module Mailers
    # This class is responsible for creating/delivering email
    #
    class EmailNotifier < ActionMailer::Base
      default from: 'curate@nd.edu', return_path: 'no-reply@nd.edu'
      layout 'mailer'

      def confirmation_of_entity_submitted_for_review(options = {})
        entity = options.fetch(:entity)
        @entity = convert_entity_into_decorator(entity)
        mail(options.slice(:to, :cc, :bcc))
      end

      def request_revision_from_creator(entity:, to:, cc: [], bcc: [])
        @entity = convert_entity_into_decorator(entity)
        mail(to: to, cc: cc, bcc: bcc)
      end

      def entity_ready_for_review(options = {})
        entity = options.fetch(:entity)
        @entity = options.fetch(:decorator) { Decorators::EmailNotificationDecorator }.new(entity.work)
        mail(options.slice(:to, :cc, :bcc))
      end

      def entity_ready_for_cataloging(entity:, to:, cc: [], bcc: [])
        @entity = convert_entity_into_decorator(entity)
        mail(to: to, cc: cc, bcc: bcc)
      end

      def confirmation_of_entity_ingested(entity:, to:, cc: [], bcc: [])
        @entity = convert_entity_into_decorator(entity)
        mail(to: to, cc: cc, bcc: bcc)
      end

      def advisor_requests_change(options = {})
        entity = options.fetch(:entity)
        @entity = options.fetch(:decorator) { Decorators::Email::AdvisorRequestsChangeDecorator }.new(entity)
        mail(options.slice(:to, :cc, :bcc))
      end

      def grad_school_requests_change(entity:, to:, cc: [], bcc: [])
        @entity = convert_entity_into_decorator(entity)
        mail(to: to, cc: cc, bcc: bcc)
      end

      def confirmation_of_grad_school_signoff(entity:, to:, cc: [], bcc: [])
        @entity = convert_entity_into_decorator(entity)
        mail(to: to, cc: cc, bcc: bcc)
      end

      def all_advisors_have_signed_off(entity:, to:, cc: [], bcc: [])
        @entity = convert_entity_into_decorator(entity)
        mail(to: to, cc: cc, bcc: bcc)
      end

      def advisor_signoff_but_still_more_to_go(entity:, to:, cc: [], bcc: [])
        @entity = convert_entity_into_decorator(entity)
        mail(to: to, cc: cc, bcc: bcc)
      end

      private

      def convert_entity_into_decorator(entity)
        Decorators::EmailNotificationDecorator.new(entity)
      end
    end
  end
end
