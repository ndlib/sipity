require "rails_helper"
require 'sipity/queries/notification_queries'
require 'sipity/parameters/notification_context_parameter'

module Sipity
  module Queries
    RSpec.describe NotificationQueries, type: :isolated_repository_module do

      context '#email_notifications_for' do
        let(:reason_for_notification) { Parameters::NotificationContextParameter::REASON_ACTION_IS_TAKEN }
        let(:another_reason_for_notification) { Parameters::NotificationContextParameter::REASON_ENTERED_STATE }
        let(:scope_for_notification) { Models::Processing::StrategyAction.new(id: 1) }
        let(:separate_scope_for_notification) { Models::Processing::StrategyAction.new(id: 2) }
        let!(:email_not_to_send) { Models::Notification::Email.create!(method_name: 'not_to_send') }
        let!(:email_to_send) { Models::Notification::Email.create!(method_name: 'to_send') }
        before do
          Models::Notification::NotifiableContext.create!(
            scope_for_notification_id: scope_for_notification.id,
            scope_for_notification_type: PowerConverter.convert(scope_for_notification, to: :polymorphic_type),
            reason_for_notification: reason_for_notification,
            email: email_to_send
          )
          Models::Notification::NotifiableContext.create!(
            scope_for_notification_id: scope_for_notification.id,
            scope_for_notification_type: PowerConverter.convert(scope_for_notification, to: :polymorphic_type),
            reason_for_notification: another_reason_for_notification,
            email: email_not_to_send
          )
          Models::Notification::NotifiableContext.create!(
            scope_for_notification_id: separate_scope_for_notification.id,
            scope_for_notification_type: PowerConverter.convert(separate_scope_for_notification, to: :polymorphic_type),
            reason_for_notification: another_reason_for_notification,
            email: email_not_to_send
          )
        end

        it 'will return the email objects' do
          expect(test_repository.email_notifications_for(reason: reason_for_notification, scope: scope_for_notification)).
            to eq([email_to_send])
        end
      end
    end
  end
end
