require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/plan_of_study_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe PlanOfStudyForm do
          let(:user) { double('User') }
          let(:work) { double('Work') }
          let(:expected_graduation_term) { 'Summer 2015' }
          let(:majors) { 'Computer Science' }
          let(:minors) { 'A Minor' }
          let(:primary_college) { 'Arts and Letters' }
          let(:underclass_level) { 'First Year' }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { requested_by: user, attributes: {}, work: work, repository: repository } }
          subject { described_class.new(keywords) }

          before do
            allow(repository).to receive(
              :get_controlled_vocabulary_values_for_predicate_name
            ).with(name: "college").and_return([primary_college])
            allow(repository).to receive(
              :get_controlled_vocabulary_values_for_predicate_name
            ).with(name: 'underclass_level').and_return([underclass_level])
            allow(repository).to receive(:possible_expected_graduation_terms).and_return([expected_graduation_term])
          end

          its(:processing_action_name) { is_expected.to eq('plan_of_study') }
          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }
          its(:base_class) { is_expected.to eq(Models::Work) }
          it { is_expected.to delegate_method(:possible_expected_graduation_terms).to(:repository) }

          context 'class configuration' do
            subject { described_class }
            its(:model_name) { is_expected.to eq(Models::Work.model_name) }
            it 'will delegate human_attribute_name to the base class' do
              expect(described_class.base_class).to receive(:human_attribute_name).and_call_original
              expect(described_class.human_attribute_name(:title)).to be_a(String)
            end
          end

          it { is_expected.not_to be_persisted }
          it { is_expected.to respond_to :work }
          it { is_expected.to respond_to :expected_graduation_term }
          it { is_expected.to respond_to :majors }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:expected_graduation_term) }
          it { is_expected.to validate_inclusion_of(:expected_graduation_term).in_array(subject.possible_expected_graduation_terms) }
          it { is_expected.to validate_presence_of(:primary_college) }
          it { is_expected.to validate_inclusion_of(:primary_college).in_array(subject.possible_primary_colleges) }
          it { is_expected.to validate_presence_of(:underclass_level) }
          it { is_expected.to validate_inclusion_of(:underclass_level).in_array(subject.possible_underclass_levels) }

          it 'will be invalid if all of the input majors are blank' do
            subject = described_class.new(keywords.merge(attributes: { majors: ['', ''] }))
            subject.valid?
            expect(subject.errors[:majors]).to be_present
          end

          it 'will be invalid if majors is blank' do
            subject = described_class.new(keywords.merge(attributes: { majors: "" }))
            subject.valid?
            expect(subject.errors[:majors]).to be_present
          end

          it 'will not require minors' do
            subject = described_class.new(keywords.merge(attributes: { minors: ['', ''] }))
            subject.valid?
            expect(subject.errors[:minors]).to_not be_present
          end

          it 'will be valid if at least one of the input majors is not blank' do
            subject = described_class.new(keywords.merge(attributes: { majors: ['chocolate', ''] }))
            subject.valid?
            expect(subject.errors[:majors]).to_not be_present
          end

          context 'retrieving values from the repository' do
            context 'with data from the database' do
              let(:expected_graduation_term) { Time.zone.today }
              let(:majors) { 'Computer Science' }
              let(:minors) { 'Book' }
              subject { described_class.new(keywords) }
              it 'will return the expected_graduation_term of the work' do
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'expected_graduation_term', cardinality: 1).and_return(expected_graduation_term)
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'majors', cardinality: :many).and_return([majors])
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'minors', cardinality: :many).and_return([minors])
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: "primary_college", cardinality: 1).and_return(primary_college)
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'underclass_level', cardinality: 1).and_return(underclass_level)

                expect(subject.expected_graduation_term).to eq expected_graduation_term
                expect(subject.majors).to eq [majors]
                expect(subject.minors).to eq [minors]
                expect(subject.primary_college).to eq(primary_college)
                expect(subject.underclass_level).to eq(underclass_level)
              end
            end
          end
          context '#submit' do
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit)
              end
            end

            context 'with valid data' do
              subject do
                described_class.new(
                  keywords.merge(
                    attributes: {
                      expected_graduation_term: expected_graduation_term, majors: majors, minors: minors, primary_college: primary_college,
                      underclass_level: underclass_level
                    }
                  )
                )
              end
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, key: 'expected_graduation_term', values: expected_graduation_term
                ).and_call_original
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, key: 'majors', values: [majors]
                ).and_call_original
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, key: 'minors', values: [minors]
                ).and_call_original
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, key: "primary_college", values: primary_college
                ).and_call_original
                expect(repository).to receive(:update_work_attribute_values!).with(
                  work: work, key: 'underclass_level', values: underclass_level
                ).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
