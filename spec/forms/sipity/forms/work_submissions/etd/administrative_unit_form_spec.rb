require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/administrative_unit_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe AdministrativeUnitForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:administrative_unit) { ['administrative_unit_name'] }
          let(:attributes) { {} }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { work: work, requested_by: double, repository: repository, attributes: attributes } }
          subject { described_class.new(keywords) }

          before do
            allow(repository).to receive(:work_attribute_values_for).
              with(work: work, key: 'administrative_unit', cardinality: :many).and_return(nil)
          end

          its(:processing_action_name) { is_expected.to eq('administrative_unit') }
          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }

          it { is_expected.to respond_to :work }
          it { is_expected.to respond_to :administrative_unit }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:administrative_unit) }
          it { is_expected.to validate_presence_of(:work) }

          context 'validations' do
            it 'will require a requested_by' do
              expect { described_class.new(keywords.merge(requested_by: nil)) }.
                to raise_error(Exceptions::InterfaceCollaboratorExpectationError)
            end
            it 'will require an administrative unit' do
              subject.valid?
              expect(subject.errors[:administrative_unit]).to be_present
            end
          end

          it 'will have #available_administrative_units' do
            expect(repository).to receive(:get_controlled_vocabulary_values_for_predicate_name).with(name: 'administrative_units').
              and_return(['administrative_unit', 'something'])
            expect(subject.available_administrative_units).to be_a(Array)
          end

          context 'retrieving values from the repository' do
            let(:administrative_unit) { ['A Specific College'] }
            subject { described_class.new(keywords) }
            it 'will return the administrative_unit of the work' do
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'administrative_unit', cardinality: :many).and_return(administrative_unit)
              expect(subject.administrative_unit).to eq ['A Specific College']
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
              it 'will not create create any additional attributes entries' do
                expect { subject.submit }.
                  to_not change { Models::AdditionalAttribute.count }
              end
            end

            context 'with valid data' do
              subject do
                described_class.new(keywords.merge(attributes: { administrative_unit: ['A Specific College'] }, repository: repository))
              end
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).exactly(1).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
