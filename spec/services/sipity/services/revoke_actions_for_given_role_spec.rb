require 'rails_helper'
require 'sipity/services/revoke_actions_for_given_role'

module Sipity
  module Services
    # Responsible for revoking action permission
    RSpec.describe RevokeActionsForGivenRole do
      let(:strategy_id) { 2 }
      let(:role) { Models::Role.new(id: 3) }
      let(:other_role) { Models::Role.new(id: 4) }
      let(:strategy_role) { Models::Processing::StrategyRole.new(strategy_id: strategy_id, role_id: role.id) }
      let(:strategy_role_other) { Models::Processing::StrategyRole.new(strategy_id: strategy_id, role_id: other_role.id) }
      let(:action_names) { ["action_one", "action_two"] }
      let(:strategy_state_names) { double }
      before do
        strategy_role.save!
        strategy_role_other.save!

        action_one = Models::Processing::StrategyAction.create!(strategy_id: strategy_id, name: "action_one")
        action_two = Models::Processing::StrategyAction.create!(strategy_id: strategy_id, name: "action_two")
        action_three = Models::Processing::StrategyAction.create!(strategy_id: strategy_id, name: "action_three")

        state_one = Models::Processing::StrategyState.create!(strategy_id: strategy_id, name: "state_one")
        state_two = Models::Processing::StrategyState.create!(strategy_id: strategy_id, name: "state_two")
        state_three = Models::Processing::StrategyState.create!(strategy_id: strategy_id, name: "state_three")

        Models::Processing::StrategyStateAction.create!(originating_strategy_state: state_two, strategy_action: action_one).tap do |obj|
          Models::Processing::StrategyStateActionPermission.create!(strategy_state_action: obj, strategy_role: strategy_role_other)
        end
        Models::Processing::StrategyStateAction.create!(originating_strategy_state: state_one, strategy_action: action_one).tap do |obj|
          Models::Processing::StrategyStateActionPermission.create!(strategy_state_action: obj, strategy_role: strategy_role)
          Models::Processing::StrategyStateActionPermission.create!(strategy_state_action: obj, strategy_role: strategy_role_other)
        end
        Models::Processing::StrategyStateAction.create!(originating_strategy_state: state_one, strategy_action: action_two) do |obj|
          Models::Processing::StrategyStateActionPermission.create!(strategy_state_action: obj, strategy_role: strategy_role)
        end
        Models::Processing::StrategyStateAction.create!(originating_strategy_state: state_two, strategy_action: action_two).tap do |obj|
          Models::Processing::StrategyStateActionPermission.create!(strategy_state_action: obj, strategy_role: strategy_role)
          Models::Processing::StrategyStateActionPermission.create!(strategy_state_action: obj, strategy_role: strategy_role_other)
        end
        Models::Processing::StrategyStateAction.create!(originating_strategy_state: state_three, strategy_action: action_three) do |obj|
          Models::Processing::StrategyStateActionPermission.create!(strategy_state_action: obj, strategy_role: strategy_role)
        end
        Models::Processing::StrategyStateAction.create!(originating_strategy_state: state_one, strategy_action: action_three) do |obj|
          Models::Processing::StrategyStateActionPermission.create!(strategy_state_action: obj, strategy_role: strategy_role_other)
        end
      end
      describe '.call' do
        it 'will, within the context of the given strategy_id, revoke permission to the actions in the states for the given role' do
          # Note: while I've given multiple action names and strategy_state_names only action_one & state_one are permitted for
          # the given role
          expect do
            described_class.call(
              role: role,
              strategy_id: strategy_id,
              action_names: ["action_one", "action_three"],
              strategy_state_names: ["state_one", "state_two"]
            )
          end.to change { Models::Processing::StrategyStateActionPermission.count }.by(-1)
        end
      end
    end
  end
end
