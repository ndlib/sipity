require 'rails_helper'
require 'sipity/services/revoke_processing_permission'

module Sipity
  module Services
    RSpec.describe RevokeProcessingPermission do
      let(:entity) { Models::Processing::Entity.new(id: 1, strategy_id: strategy.id, strategy: strategy) }
      let(:strategy) { Models::Processing::Strategy.new(id: 2) }
      let(:role) { Models::Role.new(id: 3) }
      let(:actor) { Models::Processing::Actor.new(id: 4) }
      let(:strategy_role) { Models::Processing::StrategyRole.new(strategy_id: strategy.id, role_id: role.id) }
      let(:strategy_responsibility) do
        Sipity::Models::Processing::StrategyResponsibility.new(actor_id: actor.id, strategy_role_id: strategy_role.id)
      end

      subject { described_class.new(entity: entity, role: role, actor: actor) }

      context '.call' do
        it 'will instantiate then call the instance' do
          expect(described_class).to receive(:new).and_return(double(call: true))
          described_class.call(entity: entity, role: role, actor: actor)
        end
      end

      context '#call' do
        let(:fake_relation) { double(first!: strategy_role) }
        before do
        end
        it 'will return true if role is not valid for the strategy' do
          expect(subject.call).to eq(true)
        end
        it 'will destroy an entity specific entry if one exists [strategy,role]' do
          strategy_role.save!
          Models::Processing::EntitySpecificResponsibility.create!(
            strategy_role_id: strategy_role.id, entity_id: entity.id, actor_id: actor.id
          )
          expect do
            expect do
              subject.call
            end.to change { Models::Processing::EntitySpecificResponsibility.count }.by(-1)
          end.to_not change { Models::Processing::StrategyResponsibility.count }
        end
        it 'will not destroy anything if an entity specific entry does not exist for [strategy,role]' do
          strategy_role.save!
          strategy_responsibility.save!
          allow(Sipity::Models::Processing::StrategyResponsibility).to receive(:count).and_return(1)
          expect do
            expect do
              subject.call
            end.to_not change { Models::Processing::EntitySpecificResponsibility.count }
          end.to_not change { Models::Processing::StrategyResponsibility.count }
        end
      end
    end
  end
end
