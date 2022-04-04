require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/services/action_taken_on_entity'

module Sipity
  module Services
    RSpec.describe ActionTakenOnEntity do
      let(:entity) { Models::Processing::Entity.new(id: 1, strategy_id: strategy.id, strategy: strategy) }
      let(:strategy) { Models::Processing::Strategy.new(id: 2) }
      let(:requested_by) { Models::Processing::Actor.new(id: 4, proxy_for: User.new) }
      let(:on_behalf_of) { Models::Processing::Actor.new(id: 5) }
      let(:action) { Models::Processing::StrategyAction.new(id: 3, strategy_id: strategy.id, name: 'wowza') }
      let(:another_action) { Models::Processing::StrategyAction.new(id: 30, strategy_id: strategy.id, name: 'another') }
      let(:repository) { CommandRepositoryInterface.new }

      subject { described_class.new(entity: entity, requested_by: requested_by, action: action, repository: repository) }
      its(:default_repository) { is_expected.to respond_to(:log_event!) }
      its(:default_repository) { is_expected.to respond_to(:deliver_notification_for) }
      its(:default_processing_hooks) { is_expected.to respond_to(:call) }

      before { allow(subject.send(:default_processing_hooks)).to receive(:call) }

      context 'on_behalf_of behavior' do
        it 'will default to the requested_by if none are given' do
          expect(subject.on_behalf_of_actor).to eq(requested_by)
        end
        it 'will allow use the provider if one is specified' do
          subject = described_class.new(entity: entity, requested_by: requested_by, action: action, on_behalf_of: on_behalf_of)
          expect(subject.on_behalf_of_actor).to eq(on_behalf_of)
        end
      end

      [
        :register,
        :unregister,
        :unregister_entity_action
      ].each do |method_name|
        context ".#{method_name}" do
          it "will delegate do the unerlying #initialize then ##{method_name}" do
            allow(described_class).to receive(:new).and_call_original
            expect_any_instance_of(described_class).to receive(method_name)
            described_class.send(method_name, entity: entity, requested_by: requested_by, action: action)
          end
        end
      end

      context '#register' do
        let(:processing_hooks) { ->(**_keywords) {} }
        subject do
          described_class.new(
            entity: entity, requested_by: requested_by, action: action, repository: repository, on_behalf_of: on_behalf_of,
            also_register_as: another_action, processing_hooks: processing_hooks
          )
        end
        context 'with a valid action object for the given entity' do
          it 'will increment the registry' do
            expect { subject.register }.to change { Models::Processing::EntityActionRegister.count }.by(2)
          end
          it 'will log the event' do
            expect(repository).to receive(:log_event!).
              with(entity: entity, requested_by: requested_by.proxy_for, event_name: "#{action.name}/submit")
            subject.register
          end
          it 'will send notifications on the processing comment' do
            expect(repository).to receive(:deliver_notification_for).with(
              scope: action,
              the_thing: kind_of(Models::Processing::EntityActionRegister),
              requested_by: requested_by,
              on_behalf_of: on_behalf_of
            )
            subject.register
          end
          it "will call the processing_hooks for both the action and also registered action" do
            expect(processing_hooks).to receive(:call).with(
              action: action, entity: entity, on_behalf_of: on_behalf_of, requested_by: requested_by, repository: repository
            ).and_call_original
            expect(processing_hooks).to receive(:call).with(
              action: another_action, entity: entity, on_behalf_of: on_behalf_of, requested_by: requested_by, repository: repository
            ).and_call_original
            subject.register
          end
        end
      end

      context '#unregister' do
        context 'with a valid action object for the given entity' do
          it 'will attempt to destroy the entry' do
            expect { subject.unregister }.to_not change { Models::Processing::EntityActionRegister.count }
          end
        end
      end

      context '#unregister_entity_action' do
        context 'with a valid action object for the given entity' do
          it 'will increment then decrement' do
            expect { subject.register }.to change { Models::Processing::EntityActionRegister.count }.by(1)
            expect { subject.unregister_entity_action }.to change { Models::Processing::EntityActionRegister.count }.by(-1)
          end
        end
      end

      context '#register then #unregister' do
        context 'with a valid action object for the given entity' do
          it 'will increment then decrement' do
            expect { subject.register }.to change { Models::Processing::EntityActionRegister.count }.by(1)
            expect { subject.unregister }.to change { Models::Processing::EntityActionRegister.count }.by(-1)
          end
        end
      end
    end
  end
end
