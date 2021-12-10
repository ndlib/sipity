require "rails_helper"
require 'sipity/conversions/to_rof/work_converters/etd_converter'
require 'support/shared_examples/a_work_to_rof_converter'

module Sipity
  module Conversions
    module ToRof
      module WorkConverters
        RSpec.describe EtdConverter do
          it_behaves_like 'a work to rof converter', af_model: 'Etd', attachment_predicate_name: :all

          context '#replaced_attachments' do
            let(:work) do
              Models::Work.new(id: 'abcd-ef', created_at: Time.zone.today)
            end
            let(:attachment) { Sipity::Models::Attachment.new(id: 'attachment', created_at: Time.zone.today - 3.days,updated_at: Time.zone.today, work: work) }
            let(:repository) { QueryRepositoryInterface.new }
            let(:subject) { described_class.new(work: work, repository: repository) }
            # before { allow(repository).to receive(:work_attachments).and_call_original }
            # let(:attachment_predicate_name) { parameters.fetch(:attachment_predicate_name) }
            it "should retrieve modified attachments" do
              expect(repository).to receive(:replaced_work_attachments).with(
                work: work, predicate_name: :all
              ).and_return(attachment)
              expect(subject.replaced_attachments).to eq([attachment])
            end
          end

          context '#collaborator_metadata' do
            let(:work) do
              Models::Work.new(id: 'abcd-ef', access_right: access_right, created_at: Time.zone.today)
            end
            let(:access_right) { Models::AccessRight.new(access_right_code: Models::AccessRight::OPEN_ACCESS) }
            let(:collaborator) { Models::Collaborator.new(role: Models::Collaborator::ADVISING_FACULTY_ROLE, name: 'Alexander Hamilton') }
            let(:repository) { QueryRepositoryInterface.new }
            let(:converter) { described_class.new(work: work, repository: repository) }
            subject { converter.send(:collaborator_metadata) }
            before { expect(repository).to receive(:work_collaborators_for).with(work: work).and_return(collaborator) }
            it 'should be an Array of Hashes' do
              expect(subject).to eq([{ 'dc:contributor' => collaborator.name, 'ms:role' => collaborator.role }])
            end
          end
        end
      end
    end
  end
end
