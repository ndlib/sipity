require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe BasePolicy do
      let(:policy) { double('Policy') }
      let(:user) { double('User') }
      let(:entity) { double('Entity') }
      it 'exposes a .call function for convenience' do
        allow(BasePolicy).to receive(:new).with(user, entity).and_return(policy)
        expect(policy).to receive(:show?)
        BasePolicy.call(user: user, entity: entity, policy_question: :show?)
      end

      context '.define_policy_question declaration' do
        before do
          class TestPolicy < BasePolicy
            define_policy_question :create? do
              !entity.persisted?
            end
            define_policy_question :update? do
              entity.persisted?
            end
          end
        end
        subject { TestPolicy.new(user, entity) }
        after { Sipity::Policies.send(:remove_const, :TestPolicy) }

        it 'will expose an instance method' do
          # Making sure I have the right scope.
          allow(entity).to receive(:persisted?).and_return(true)
          expect(subject.update?).to be_truthy
        end

        it 'will requester the given policy question' do
          expect(subject.class.registered_policy_questions.to_a).to eq([:create?, :update?])
        end

        it 'will expose available_actions_by_policy' do
          allow(entity).to receive(:persisted?).and_return(true)
          expect(subject.available_actions_by_policy).to eq([:update?])
        end
      end
    end
  end
end
