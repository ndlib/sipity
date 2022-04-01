require "rails_helper"
require 'sipity/queries/attachment_queries'

module Sipity
  module Queries
    RSpec.describe AttachmentQueries, type: :isolated_repository_module do
      let(:work) { Models::Work.new(id: '123') }
      let(:work_two) { Models::Work.new(id: '456') }
      let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
      let(:file2) { FileUpload.fixture_file_upload('attachments/good-bye-world.txt') }
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

        context 'when ordered by :representative_first' do
          it 'returns the representative file first' do
            non_representative = Models::Attachment.create!(
              work_id: work.id, pid: 'attach1', predicate_name: 'alternate_attachment', file: file
            )
            representative = Models::Attachment.create!(
              work_id: work.id, pid: 'attach2', predicate_name: 'attachment', file: file, is_representative_file: true
            )
            expect(subject.work_attachments(work: work, order: :representative_first)).to eq([representative, non_representative])
          end
        end
      end

      context '#replaced_work_attachments' do
        let(:requesting_user) { Sipity::Factories.create_user }
        let(:requested_by_actor) { Models::Processing::Actor.new(proxy_for: requesting_user) }
        let(:attachment) { Models::Attachment.create!(work_id: work.id, pid: 'attach1', predicate_name: 'attachment', file: file, created_at: Time.now - 5.days, updated_at: Time.now - 5.days) }
        let(:attachment2) { Models::Attachment.create!(work_id: work.id, pid: 'attach2', predicate_name: 'attachment', file: file, created_at: Time.now - 5.days, updated_at: Time.now - 5.days) }
        let(:other_type) { Models::Attachment.create!(work_id: work.id, pid: 'attach3', predicate_name: 'alternate_type', file: file, created_at: Time.now - 5.days, updated_at: Time.now - 5.days) }
        let(:proxy) { double('Entity', id: 1, proxy_for_id: work.id) }

        let(:strategy) { Models::Processing::Strategy.new(id: 3) }
        let(:strategy_state) { Models::Processing::StrategyState.new(id: 2, strategy_id: strategy.id) }
        let(:update_file_action) do
          Models::Processing::StrategyAction.create!(
            strategy_id: strategy.id,
            action_type: Models::Processing::StrategyAction::STATE_ADVANCING_ACTION,
            name: 'update_file'
          )
        end
        let(:ingest_action) do
          Models::Processing::StrategyAction.create!(
            strategy_id: strategy.id,
            resulting_strategy_state_id: 4,
            action_type: Models::Processing::StrategyAction::STATE_ADVANCING_ACTION,
            name: 'ingest_completed'
          )
        end

        before do
          ingest_action
          update_file_action
          Models::Processing::EntityActionRegister.create!(
            strategy_action_id: ingest_action.id, 
            entity_id: proxy.id, 
            requested_by_actor: requested_by_actor, 
            on_behalf_of_actor: requested_by_actor, 
            subject_id: proxy.proxy_for_id, 
            subject_type: 'Sipity::Models::Work', 
            created_at: Time.now - 5.days, 
            updated_at: Time.now - 5.days
          )
          Models::Processing::EntityActionRegister.create!(
            strategy_action_id: update_file_action.id, 
            entity_id: proxy.id, 
            requested_by_actor: requested_by_actor, 
            on_behalf_of_actor: requested_by_actor, 
            subject_id: proxy.proxy_for_id, 
            subject_type: 'Sipity::Models::Work', 
            created_at: Time.now - 3.days, 
            updated_at: Time.now - 3.days
          )
          # allow(Sipity::Models::Processing::StrategyAction).to receive(:where).and_return([ingest_action])
          allow(Sipity::Models::Processing::Entity).to receive(:where).and_return([proxy])
        end

        describe 'when there is an entity action register record' do
          before do       
            attachment
            attachment2
            other_type   
            attachment2.update_version_with!(new_file: file2)
          end
          it 'finds only the replaced attachments since the last ingest' do
            expect(subject.replaced_work_attachments(work: work).map(&:pid)).to match_array(['attach2'])
            expect(subject.replaced_work_attachments(work: work, predicate_name: 'alternate_type').empty?).to be_truthy 
            expect(subject.replaced_work_attachments(work: work, predicate_name: :all).map(&:pid)).to match_array(['attach2'])
          end
        end
        describe 'when there is no entity action register record' do
          before do
            attachment
            attachment2
            other_type
            attachment2.update_version_with!(new_file: file2)
            allow(Sipity::Models::Processing::EntityActionRegister).to receive(:where).and_return([])
          end
          it 'finds any replaced attachments' do
            expect(subject.replaced_work_attachments(work: work).map(&:pid)).to match_array(['attach2'])
            expect(subject.replaced_work_attachments(work: work, predicate_name: 'alternate_type').empty?).to be_truthy 
            expect(subject.replaced_work_attachments(work: work, predicate_name: :all).map(&:pid)).to match_array(['attach2'])
          end
        end   
        describe 'when ordered by :representative_first' do
          let(:non_representative) { Models::Attachment.create!(
              work_id: work.id, pid: 'attach1', predicate_name: 'alternate_type', file: file, is_representative_file: false, created_at: Time.now - 5.days, updated_at: Time.now - 5.days
            ) }
          let(:representative) { Models::Attachment.create!(
              work_id: work.id, pid: 'attach2', predicate_name: 'attachment', file: file, is_representative_file: true, created_at: Time.now - 5.days, updated_at: Time.now - 5.days
            ) }
          before do
            non_representative
            representative
            representative.update_version_with!(new_file: file2)
            non_representative.update_version_with!(new_file: file2)
            allow(Sipity::Models::Processing::Entity).to receive(:where).and_return([proxy])
          end
          it 'returns the representative file first' do
            expect(subject.replaced_work_attachments(work: work, order: :representative_first).map(&:pid)).to eq(['attach2', 'attach1'])
          end
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
