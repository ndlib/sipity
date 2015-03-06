require 'spec_helper'

module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe DegreeForm do
        let(:work) { Models::Work.new(id: '1234') }
        let(:degree) { 'degree_name' }
        let(:program) { 'program_name' }
        let(:repository) { CommandRepositoryInterface.new }
        subject { described_class.new(work: work, repository: repository) }

        its(:enrichment_type) { should eq('degree') }
        its(:policy_enforcer) { should eq Policies::Processing::WorkProcessingPolicy }

        it { should respond_to :work }
        it { should respond_to :degree }
        it { should respond_to :program_name }

        it 'will require a degree' do
          subject.valid?
          expect(subject.errors[:degree]).to be_present
          expect(subject.errors[:program_name]).to be_present
        end

        context '#degree' do
          it 'will have #degree_names' do
            expect(repository).to receive(:get_values_by_predicate_name).with(name: 'degree').and_return(['degree_name', 'bogus'])
            expect(subject.degree_names).to be_a(Array)
          end

          context 'with data from the database' do
            subject { described_class.new(work: work, degree: ['bogus', 'test'], repository: repository) }
            it 'will return the degree of the work' do
              expect(subject.degree).to eq ['bogus', 'test']
            end
          end
          context 'when no degree is given and none is in the repository' do
            subject { described_class.new(work: work, repository: repository) }
            its(:degree) { should_not be_present }
          end
        end

        context '#program_name' do
          it 'will have #programs' do
            expect(repository).to receive(:get_values_by_predicate_name).with(name: 'program').and_return(['bogus'])
            expect(subject.programs).to be_a(Array)
          end

          context 'with data from the database' do
            subject { described_class.new(work: work, program_name: ['bogus', 'test'], repository: repository) }
            it 'will return the program of the work' do
              expect(subject.program_name).to eq ['bogus', 'test']
            end
          end

          context 'when no program is given and none is in the repository' do
            subject { described_class.new(work: work, repository: repository) }
            its(:program_name) { should_not be_present }
          end
        end

        context '#submit' do
          let(:user) { double('User') }
          context 'with invalid data' do
            before do
              expect(subject).to receive(:valid?).and_return(false)
            end
            it 'will return false if not valid' do
              expect(subject.submit(requested_by: user))
            end
          end

          context 'with valid data' do
            subject { described_class.new(work: work, degree: 'bogus', program_name: 'fake name', repository: repository) }
            before do
              expect(subject).to receive(:valid?).and_return(true)
            end

            it 'will return the work' do
              returned_value = subject.submit(requested_by: user)
              expect(returned_value).to eq(work)
            end

            it "will transition the work's corresponding enrichment todo item to :done" do
              expect(repository).to receive(:register_action_taken_on_entity).and_call_original
              subject.submit(requested_by: user)
            end

            it 'will add additional attributes entries' do
              expect(repository).to receive(:update_work_attribute_values!).exactly(2).and_call_original
              subject.submit(requested_by: user)
            end

            it 'will record the event' do
              expect(repository).to receive(:log_event!).and_call_original
              subject.submit(requested_by: user)
            end
          end
        end
      end
    end
  end
end
