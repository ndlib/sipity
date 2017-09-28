require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/banner_program_code_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe BannerProgramCodeForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:keywords) { { work: work, requested_by: double, repository: repository } }
          subject { described_class.new(keywords) }

          before do
            allow(repository).to receive(:work_attribute_values_for).
              with(work: work, key: 'banner_program_code', cardinality: 1).and_return(nil)
          end

          its(:processing_action_name) { is_expected.to eq('banner_program_code') }
          its(:policy_enforcer) { is_expected.to eq Policies::WorkPolicy }

          it { is_expected.to respond_to :work }
          it { is_expected.to respond_to :banner_program_code }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:banner_program_code) }
          it { is_expected.to validate_presence_of(:work) }
          it { is_expected.to validate_presence_of(:work) }

          context 'validations' do
            it 'will require a requested_by' do
              expect { described_class.new(keywords.merge(requested_by: nil)) }.
                to raise_error(Exceptions::InterfaceCollaboratorExpectationError)
            end
          end

          context 'retrieving values from the repository' do
            let(:banner_program_code) { 'Hello Dolly' }
            subject { described_class.new(keywords) }
            it 'will return the banner_program_code of the work' do
              expect(repository).to receive(:work_attribute_values_for).
                with(work: work, key: 'banner_program_code', cardinality: 1).and_return(banner_program_code)
              expect(subject.banner_program_code).to eq 'Hello Dolly'
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
              subject { described_class.new(keywords.merge(attributes: { banner_program_code: 'Hello Dolly' }, repository: repository)) }
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
