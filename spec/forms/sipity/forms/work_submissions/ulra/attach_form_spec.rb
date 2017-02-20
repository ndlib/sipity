require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/ulra/attach_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        RSpec.describe AttachForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: attributes } }
          let(:attributes) { {} }
          subject { described_class.new(keywords) }

          its(:policy_enforcer) { is_expected.to be_present }
          its(:processing_action_name) { is_expected.to eq('attach') }
          its(:attachment_predicate_name) { is_expected.to eq('project_file') }

          it { is_expected.to respond_to :attachments }
          it { is_expected.to respond_to :representative_attachment_id }
          it { is_expected.to respond_to :files }
          it { is_expected.to respond_to :attached_files_completion_state }
          it { is_expected.to respond_to :project_url }

          it { is_expected.to delegate_method(:at_least_one_file_must_be_attached).to(:attachments_extension) }

          context 'values from work' do
            before do
              allow(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'attached_files_completion_state', cardinality: 1
              ).and_return('complete')
              allow(repository).to receive(:work_attribute_values_for).with(
                work: work, key: 'project_url', cardinality: 1
              ).and_return('existing.url')
            end
            its(:attached_files_completion_state_from_work) { is_expected.to eq('complete') }
            its(:attached_files_completion_state) { is_expected.to eq('complete') }
          end

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:work) }
          it { is_expected.to validate_presence_of(:requested_by) }
          it { is_expected.to validate_presence_of(:attached_files_completion_state) }
          it do
            is_expected.to validate_inclusion_of(:attached_files_completion_state).in_array(
              subject.possible_attached_files_completion_states
            )
          end

          context '#project_url validation' do
            it 'will allow a blank URL' do
              attributes = keywords[:attributes].merge(project_url: '')
              form = described_class.new(keywords.merge(attributes: attributes))
              form.valid?
              expect(form.errors[:project_url]).to be_empty
            end
            it 'will disallow a malconfigured URL' do
              attributes = keywords[:attributes].merge(project_url: 'ftp://chicken.com')
              form = described_class.new(keywords.merge(attributes: attributes))
              form.valid?
              expect(form.errors[:project_url]).not_to be_empty
            end
          end

          context '#project_url' do
            it 'will prepend http:// if the input is present but does not have http://' do
              form = described_class.new(keywords.merge(attributes: { project_url: 'google.com' }))
              expect(form.project_url).to eq('http://google.com')
            end
            it 'will not prepend http:// if the input is present but has a prefix of http://' do
              form = described_class.new(keywords.merge(attributes: { project_url: 'http://google.com' }))
              expect(form.project_url).to eq('http://google.com')
            end
            it 'will not http:// if the input is not present' do
              form = described_class.new(keywords.merge(attributes: { project_url: '' }))
              expect(form.project_url).to eq('')
            end
          end

          context 'assigning attachments attributes' do
            let(:user) { double('User') }
            let(:attributes) do
              {
                attachments_attributes:
                {
                  "0" => { "name" => "code4lib.pdf", "delete" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
                  "1" => { "name" => "hotel.pdf", "delete" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
                  "2" => { "name" => "code4lib.pdf", "delete" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" }
                }
              }
            end

            before do
              allow(subject).to receive(:valid?).and_return(true)
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end

            it 'will attach_or_update_files' do
              expect(subject.send(:attachments_extension)).to receive(:attach_or_update_files).with(requested_by: subject.requested_by)
              subject.submit
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
              it 'will not create any attachments' do
                expect { subject.submit }.
                  to_not change { Models::Attachment.count }
              end
            end

            context 'with valid data' do
              let(:attributes) do
                { files: [file], remove_files: [remove_file], project_url: 'the.url', attached_files_completion_state: 'complete' }
              end
              let(:file) { double('A File') }
              let(:remove_file) { double('File to delete') }

              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
                allow(repository).to receive(:update_work_attribute_values!)
              end

              it 'will attach each file' do
                expect(repository).to receive(:attach_files_to).and_call_original
                subject.submit
              end

              it 'will mark a file as representative' do
                expect(repository).to receive(:set_as_representative_attachment).and_call_original
                subject.submit
              end

              it 'will persist the project_url' do
                expect(repository).to receive(
                  :update_work_attribute_values!
                ).with(work: work, key: 'project_url', values: 'http://the.url').and_call_original
                subject.submit
              end

              it 'will persist the attached_files_completion_state' do
                expect(repository).to receive(
                  :update_work_attribute_values!
                ).with(work: work, key: 'attached_files_completion_state', values: 'complete').and_call_original
                subject.submit
              end
            end
          end
        end
      end
    end
  end
end
