require 'spec_helper'
require 'sipity/queries/attachment_queries'

module Sipity
  module Queries
    RSpec.describe AttachmentQueries, type: :isolated_repository_module do
      let(:work) { Models::Work.new(id: '123') }
      let(:work_two) { Models::Work.new(id: '456') }
      let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
      subject { test_repository }

      context '#find_or_initialize_attachments' do
        subject { test_repository.find_or_initialize_attachments_by(work: work, pid: '12') }
        it 'will initialize a attachment based on the work id' do
          expect(subject.work_id).to eq(work.id.to_s)
        end
      end

      context '#work_attachments' do
        it 'returns the attachments for the given work and role' do
          attachment = Models::Attachment.create!(work_id: work.id, pid: 'attach1', predicate_name: 'attachment', file: file)
          other_type = Models::Attachment.create!(work_id: work.id, pid: 'attach2', predicate_name: 'alternate_attachment', file: file)
          expect(subject.work_attachments(work: work)).to eq([attachment, other_type])
          expect(subject.work_attachments(work: work, predicate_name: 'alternate_attachment')).to eq([other_type])
          expect(subject.work_attachments(work: work, predicate_name: :all)).to eq([attachment, other_type])
        end
      end

      context '#accessible_objects' do
        it 'returns the attachments for the given work and role' do
          attachment = Models::Attachment.create!(work_id: work.id, pid: 'attach1', predicate_name: 'attachment', file: file)
          expect(subject.accessible_objects(work: work)).to eq([work, attachment])
        end
      end

      context '#representative_attachment_for' do
        it 'returns attachment marked as representative for work' do
          attachment = Models::Attachment.create!(
            work_id: work.id, pid: 'attach1', predicate_name: 'attachment',
            file: file, is_representative_file: true
          )
          expect(subject.representative_attachment_for(work: work)).to eq(attachment)
        end
      end

      context '#access_rights_for_accessible_objects' do
        let(:attachment) { Models::Attachment.new(id: 'abc') }
        it 'returns an enumerable of AccessRight objects' do
          allow(test_repository).to receive(:accessible_objects).and_return([work, attachment])
          access_rights = test_repository.access_rights_for_accessible_objects_of(work: work)
          expect(access_rights.size).to eq(2)
          expect(access_rights[0]).to be_a(Models::AccessRightFacade)
          expect(access_rights[1]).to be_a(Models::AccessRightFacade)
        end
      end

      context '#attachment_access_right' do
        it 'will expose access_right_code of the underlying attachment' do
          attachment = Models::Attachment.create!(work_id: work.id, pid: 'attach1', predicate_name: 'attachment', file: file)
          access_right = Models::AccessRight.create!(entity: attachment, access_right_code: 'private_access')
          expect(test_repository.attachment_access_right(attachment: attachment)).to eq(access_right)
        end

        it "will fallback to the work's access_right_code" do
          attachment = Models::Attachment.create!(work_id: work.id, pid: 'attach1', predicate_name: 'attachment', file: file)
          access_right = Models::AccessRight.create!(entity: work, access_right_code: 'private_access')
          expect(test_repository.attachment_access_right(attachment: attachment)).to eq(access_right)
        end
      end
    end
  end
end
