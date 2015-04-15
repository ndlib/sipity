require 'spec_helper'

module Sipity
  module Forms
    module WorkEnrichments
      RSpec.describe PlanOfStudyForm do
        let(:work) { Models::Work.new(id: '1234') }
        let(:expected_graduation_date) { Time.zone.today }
        let(:majors) { 'Computer Science' }
        let(:repository) { CommandRepositoryInterface.new }
        subject { described_class.new(work: work, repository: repository) }

        its(:enrichment_type) { should eq('plan_of_study') }
        its(:policy_enforcer) { should eq Policies::Processing::WorkProcessingPolicy }

        it { should respond_to :work }
        it { should respond_to :expected_graduation_date }
        it { should respond_to :majors }

        it 'will require a expected_graduation_date' do
          subject.valid?
          expect(subject.errors[:expected_graduation_date]).to be_present
        end

        it 'will require a major' do
          subject.valid?
          expect(subject.errors[:majors]).to be_present
        end
        context 'retrieving values from the repository' do
          context 'with data from the database' do
            let(:expected_graduation_date) { Time.zone.today }
            let(:majors) { 'Computer Science' }
            subject { described_class.new(work: work, repository: repository) }
            it 'will return the expected_graduation_date of the work' do
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'expected_graduation_date').and_return(expected_graduation_date)
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'majors').and_return([majors])
              expect(subject.expected_graduation_date).to eq expected_graduation_date
              expect(subject.majors).to eq [majors]
            end
          end
          context 'when initial date is given is bogus' do
            subject { described_class.new(work: work, expected_graduation_date: '2014-02-31', repository: repository) }
            its(:expected_graduation_date) { should_not be_present }
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
            subject do
              described_class.new(
                work: work, expected_graduation_date: expected_graduation_date, majors: majors, repository: repository
              )
            end
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
