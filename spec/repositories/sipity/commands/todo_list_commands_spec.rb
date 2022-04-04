require "rails_helper"
require 'sipity/commands/todo_list_commands'

module Sipity
  module Commands
    RSpec.describe TodoListCommands, type: :isolated_repository_module do
      let(:work) { Models::Work.new(id: 1, work_type: 'doctoral_dissertation') }
      let(:user) { double }

      context '#register_action_taken_on_entity' do
        let(:existing_action) { 'describe' }
        it "will call the underlying service object" do
          expect(Services::ActionTakenOnEntity).to receive(:register)
          test_repository.register_action_taken_on_entity(entity: work, action: existing_action, requested_by: user)
        end
      end

      context '#unregister_action_taken_on_entity' do
        let(:existing_action) { 'describe' }
        it "will call the underlying service object" do
          expect(Services::ActionTakenOnEntity).to receive(:unregister)
          test_repository.unregister_action_taken_on_entity(entity: work, action: existing_action, requested_by: user)
        end
      end

      context '#unregister_action_taken_on_entity_by_anyone' do
        let(:existing_action) { 'describe' }
        it "will call the underlying service object" do
          expect(Services::ActionTakenOnEntity).to receive(:unregister_entity_action)
          test_repository.unregister_action_taken_on_entity_by_anyone(entity: work, action: existing_action, requested_by: user)
        end
      end

      context '#record_processing_comment' do
        let(:entity) { Models::Processing::Entity.new(id: 1, strategy_id: strategy.id, strategy_state_id: state.id, strategy_state: state) }
        let(:actor) { Models::Processing::Actor.new(id: 2) }
        let(:action) { Models::Processing::StrategyAction.new(id: 3, strategy_id: strategy.id) }
        let(:strategy) { Models::Processing::Strategy.new(id: 4) }
        let(:state) { Models::Processing::StrategyState.new(id: 5) }
        let(:comment) { 'Hello World' }
        it "will create a Models::Processing::Comment" do
          expect(
            test_repository.record_processing_comment(entity: entity, commenter: actor, action: action, comment: comment)
          ).to be_a(Models::Processing::Comment)
        end
      end
    end
  end
end
