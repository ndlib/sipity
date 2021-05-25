require "rails_helper"

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe DoiCompletedForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:processing_action) { Models::Processing::StrategyAction.new(name: 'doi_completed') }
          let(:attributes) { { job_state: described_class::JOB_STATE_SUCCESS } }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: attributes } }
          let(:user) { double('User') }
          subject { described_class.new(keywords) }

          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }
          its(:processing_action_name) { is_expected.to eq('doi_completed') }

          it { is_expected.to respond_to :job_state }

          it { is_expected.to respond_to :work }
          it { is_expected.to delegate_method(:submit).to(:processing_action_form) }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_inclusion_of(:job_state).in_array([described_class::JOB_STATE_SUCCESS]) }

          context 'with "error" for job_state' do
            let(:attributes) { { job_state: described_class::JOB_STATE_ERROR } }
            before do
              allow(subject).to receive(:valid?).and_return(true)
            end
            it 'will notify Sentry' do
              expect(Raven).to receive(:capture_exception).and_call_original
              subject.submit
            end
            it 'will not save doi on work' do
              expect(subject).to_not receive(:save_doi_on_work)
              subject.submit
            end
            it 'will not submit the underlying processing form' do
              expect(subject.send(:processing_action_form)).to_not receive(:submit)
              subject.submit
            end
            its(:submit) { is_expected.to eq(work) }
          end

          context 'with "processing" for job_state' do
            let(:attributes) { { job_state: described_class::JOB_STATE_PROCESSING } }
            before do
              allow(subject).to receive(:valid?).and_return(true)
            end
            it 'will NOT notify Sentry' do
              expect(Raven).not_to receive(:capture_exception)
              subject.submit
            end
            it 'will not save doi on work' do
              expect(subject).to_not receive(:save_doi_on_work)
              subject.submit
            end
            it 'will not submit the underlying processing form' do
              expect(subject.send(:processing_action_form)).to_not receive(:submit)
              subject.submit
            end
            its(:submit) { is_expected.to eq(work) }
          end

          context 'with invalid data' do
            before { expect(subject).to receive(:valid?).and_return(false) }
            its(:submit) { is_expected.to eq(false) }
          end

          context 'with valid data' do
            before do
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end
            it 'register the doi attribute on the work' do
              expect(repository).to receive(:update_work_attribute_values!).with(work: work, key: 'identifier_doi', values: kind_of(String))
              subject.submit
            end
          end
        end
      end
    end
  end
end
