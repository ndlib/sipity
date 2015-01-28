require 'spec_helper'

module Sipity
  module Policies
    RSpec.describe WorkEventTriggerPolicy do
      let(:user) { User.new(id: 123) }
      let(:work) { Models::Work.new(id: 123, work_type: 'etd', processing_state: 'new') }
      let(:event_name) { 'approve_for_ingest' }
      let(:state_diagram) { StateMachines::EtdStateMachine::STATE_POLICY_QUESTION_ROLE_MAP }
      let(:form) { double('Form', work: work, event_name: event_name, state_diagram: state_diagram) }
      subject { described_class.new(user, form) }

      context 'for a non-authenticated user' do
        let(:user) { nil }
        its(:submit?) { should eq(false) }
      end

      context 'for a non-persisted entity' do
        its(:submit?) { should eq(false) }
      end

      context 'for a user and persisted entity' do
        before { expect(work).to receive(:persisted?).and_return(true) }
        context 'and event trigger is for an invalid' do
          its(:submit?) { should eq(false) }
        end

        context 'and event triggered by user without access' do
          let(:event_name) { 'submit_for_review' }
          xit { its(:submit?) { should eq(false) } }
        end

        xit 'disallows submitting a trigger for a work in which all todo items are not complete'
      end
    end
  end
end
