require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/core/update_file_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe UpdateFileForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: attributes } }
          let(:attributes) { {} }
          subject { described_class.new(keywords) }

          its(:policy_enforcer) { is_expected.to be_present }
          its(:processing_action_name) { is_expected.to eq('update_file') }

          it { is_expected.to respond_to :attachments }
          it { is_expected.to respond_to :files }
          
          it { is_expected.to delegate_method(:only_one_file_may_be_selected).to(:attachments_extension) }
          it { is_expected.to delegate_method(:only_one_file_may_be_uploaded).to(:attachments_extension) }

          context 'validations' do
            it 'will require a work' do
              subject = described_class.new(keywords.merge(work: nil))
              subject.valid?
              expect(subject.errors[:work]).to_not be_empty
            end

            it 'will have #attachments' do
              attachment = [double('Attachment')]
              expect(repository).to receive(:work_attachments).and_return(attachment)
              expect(subject.attachments).to_not be_empty
            end
          end

          context 'assigning attachments attributes' do
            let(:user) { double('User') }
            let(:attributes) do
              {
                attachments_attributes:
                {
                  "0" => { "name" => "code4lib.pdf", "replace" => "1", "id" => "i8tnddObffbIfNgylX7zSA==" },
                  "1" => { "name" => "hotel.pdf", "replace" => "0", "id" => "y5Fm8YK9-ekjEwUMKeeutw==" },
                  "2" => { "name" => "code4lib.pdf", "replace" => "0", "id" => "64Y9v5yGshHFgE6fS4FRew==" }
                }
              }
            end

            before do
              allow(subject).to receive(:valid?).and_return(true)
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end

            it 'will attach_new_version of file' do
              expect(subject.send(:attachments_extension)).to receive(:attach_new_version).with(requested_by: subject.requested_by)
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
              let(:attributes) { { files: [file], replace: [replacement] } }
              let(:file) { double('A File') }
              let(:replacement) { double('File to replace') }

              before do
                allow(subject).to receive(:valid?).and_return(true)
                allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
              end

              it 'will update attachments' do
                expect(repository).to receive(:replace_file_version).and_call_original
                subject.submit
              end

              it 'will not create any new attachments' do
                expect { subject.submit }.
                  to_not change { Models::Attachment.count }
              end
            end
          end
        end
      end
    end
  end
end
