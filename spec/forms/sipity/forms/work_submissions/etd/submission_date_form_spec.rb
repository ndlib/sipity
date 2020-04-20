require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/submission_date_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe SubmissionDateForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:submission_date) { Time.zone.today }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:user) { double }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: attributes } }
          subject { described_class.new(keywords) }

          its(:processing_action_name) { is_expected.to eq('submission_date') }
          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }

          it { is_expected.to respond_to :work }
          it { is_expected.to respond_to :submission_date }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:submission_date) }

          it 'will handle Rails submission_date that was input via Rails HTML multi-field date input' do
            form = described_class.new(
              keywords.merge(attributes: { 'submission_date(1i)' => "2014", 'submission_date(2i)' => "10", 'submission_date(3i)' => "1" })
            )
            expect(form.submission_date.month).to eq(10)
          end

          context '#submission_date' do
            context 'with data from the database' do
              subject { described_class.new(keywords) }
              it 'will return the submission_date of the work' do
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: Models::AdditionalAttribute::ETD_SUBMISSION_DATE, cardinality: 1).and_return(submission_date)
                expect(subject.submission_date).to eq submission_date
              end
            end
            context 'when initial date is given is bogus' do
              subject { described_class.new(keywords.merge(attributes: { submission_date: '2014-02-31' })) }
              its(:submission_date) { is_expected.not_to be_present }
            end
          end

          context '#submit' do
            let(:user) { double('User') }
            context 'with invalid data' do
              before do
                expect(subject).to receive(:valid?).and_return(false)
              end
              it 'will return false if not valid' do
                expect(subject.submit)
              end
            end

            context 'with valid data' do
              subject { described_class.new(keywords.merge(attributes: { submission_date: '2014-10-02' })) }
              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will add additional attributes entries' do
                expect(repository).to receive(:update_work_attribute_values!).and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
