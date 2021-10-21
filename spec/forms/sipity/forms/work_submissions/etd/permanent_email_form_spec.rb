require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/submission_date_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe PermanentEmailForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:permanent_email) { 'someone@example.com'}
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:user) { double }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: attributes } }

          let(:subject) { described_class.new(keywords) }

          its(:processing_action_name) { is_expected.to eq('permanent_email') }
          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }

          it { is_expected.to respond_to :work }
          it { is_expected.to respond_to :permanent_email }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:permanent_email) }

          context 'form content' do
            context 'with data from the database' do
              subject { described_class.new(keywords) }
              it 'will return the permanent_email of the work' do
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: Models::AdditionalAttribute::PERMANENT_EMAIL, cardinality: 1).and_return(permanent_email)
                expect(subject.permanent_email).to eq permanent_email
              end
            end
            context 'when email is not in database' do
              subject { described_class.new(keywords) }
              its(:permanent_email) { is_expected.not_to be_present }
            end
          end

          context '#submit' do
            let(:user) { double('User') }

            context 'with no content' do
              subject { described_class.new(keywords) }

              it 'will return false' do
                expect(subject.submit).to eq(false)
              end
            end

            context 'with content' do
              subject { described_class.new(keywords.merge(attributes: { permanent_email: permanent_email })) }
              before do
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
