require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe SubmitForIngestForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:keywords) { { work: work, repository: repository, requested_by: double, attributes: attributes } }
          subject { described_class.new(keywords) }

          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }

          it { is_expected.to respond_to :work }

          context '#submit' do
            let(:user) { double('User') }
            context 'with invalid data' do
              before do
                expect(repository).to receive(:authorized_for_processing?).and_return(false)
                expect(subject.send(:exporter)).to_not receive(:call)
              end
              it 'will return false if not valid' do
                expect(subject.submit)
              end
            end

            context 'with valid data' do
              subject do
                described_class.new(keywords)
              end

              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will submit successfully if valid' do
                expect(subject.send(:exporter)).to receive(:call).with(work: work)
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
