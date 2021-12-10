require 'rails_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/commands/work_commands'

module Sipity
  module Commands
    RSpec.describe WorkCommands, type: :command_with_related_query do
      before do
        # TODO: Remove this once the deprecation for granting permission is done
        allow(Services::GrantProcessingPermission).to receive(:call)
      end

      context '#destroy_a_work' do
        let(:work) { Models::Work.new(id: '1') }
        it 'will destroy the work in question' do
          work.save! # so it is persisted
          expect { test_repository.destroy_a_work(work: work) }.
            to change { Models::Work.count }.by(-1)
          expect { work.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context '#manage_collaborators_for' do
        let(:work) { double('Work') }
        let(:collaborator) { double("Collaborator") }
        it 'delegates to Sipity::Services::ManageCollaborators.manage_collaborators_for' do
          expect(Services::ManageCollaborators).to receive(:manage_collaborators_for).
            with(work: work, collaborators: collaborator, repository: test_repository)
          test_repository.manage_collaborators_for(work: work, collaborators: collaborator)
        end
      end

      context '#assign_collaborators_to' do
        let(:work) { double('Work') }
        let(:collaborator) { double("Collaborator") }
        it 'delegates to Sipity::Services::ManageCollaborators.assign_collaborators_to' do
          expect(Services::ManageCollaborators).to receive(:assign_collaborators_to).
            with(work: work, collaborators: collaborator, repository: test_repository)
          test_repository.assign_collaborators_to(work: work, collaborators: collaborator)
        end
      end

      context '#create_work!' do
        let(:attributes) { { title: 'Hello', work_publication_strategy: 'do_not_know', work_type: 'doctoral_dissertation' } }
        it 'will delegate to the Services::CreateWorkService' do
          submission_window = double
          expect(Services::CreateWorkService).to receive(:call).
            with(submission_window: submission_window, repository: test_repository, **attributes)
          test_repository.create_work!(submission_window: submission_window, **attributes)
        end
      end

      context '#update_title!' do
        it 'will update title of the work object' do
          work = Models::Work.create!(id: '12', title: 'bogus')
          expect { test_repository.update_work_title!(work: work, title: 'helloworld') }.
            to change(work, :title).from('bogus').to('helloworld')
        end
      end

      context '#default_pid_minter' do
        subject { test_repository.default_pid_minter }
        it { is_expected.to respond_to(:call) }
        its(:call) { is_expected.to be_a(String) }
      end

      context '#update_processing_state!' do
        let(:work) { Models::Work.create!(id: '1') }
        it 'will update update the entity processing state' do
          expect(Services::UpdateEntityProcessingState).to receive(:call)
          test_repository.update_processing_state!(entity: work, to: 'hello')
        end
      end

      context '#attach_files_to' do
        let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
        let(:user) { User.new(id: 1234) }
        let(:work) { Models::Work.create!(id: '1') }
        let(:pid_minter) { -> { 'abc123' } }
        it 'will increment the number of attachments in the system' do
          expect { test_repository.attach_files_to(work: work, files: file, user: user, pid_minter: pid_minter) }.
            to change { Models::Attachment.where(pid: 'abc123').count }.by(1)
        end

        it 'will not increment the number of attachments in the system if we get an empty hash' do
          expect { test_repository.attach_files_to(work: work, files: {}, user: user, pid_minter: pid_minter) }.
            to_not change { Models::Attachment.where(pid: 'abc123').count }
        end
      end

      context '#replace_file_version' do
        let(:replacement) { FileUpload.fixture_file_upload('attachments/another-attachment.txt') }
        let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
        let(:user) { User.new(id: 1234) }
        let(:work) { Models::Work.create!(id: '1') }
        let(:pid_minter) { -> { 'abc123' } }
        before do
          test_repository.attach_files_to(work: work, files: file, user: user, pid_minter: pid_minter)
        end

        it 'will update the existing file and keep the original file_name' do
          expect { test_repository.replace_file_version(work: work, file: replacement, user: user, pid: 'abc123') }.
            to change { Models::Attachment.where(pid: 'abc123').count }.by(0)
          expect(Models::Attachment.where(pid: 'abc123').first.file_name).to eq('hello-world.txt')
        end
      end

      context '#remove_files_from' do
        let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
        let(:file_name) { "hello-world.txt" }
        let(:user) { User.new(id: 1234) }
        let(:work) { Models::Work.create!(id: '1') }
        let(:pid_minter) { -> { 'abc123' } }
        before { test_repository.attach_files_to(work: work, files: file, user: user, pid_minter: pid_minter) }
        it 'will decrease the number of attachments in the system' do
          expect { test_repository.remove_files_from(pids: pid_minter.call, work: work, user: user) }.
            to change { Models::Attachment.count }.by(-1)
        end

        it 'will only destroy attachments of the specified predicate' do
          expect { test_repository.remove_files_from(pids: pid_minter.call, work: work, user: user, predicate_name: 'other') }.
            to_not change { Models::Attachment.count }
        end
      end

      context '#amend_files_metadata' do
        let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
        let(:file_name) { "hello-world.txt" }
        let(:user) { User.new(id: 1234) }
        let(:work) { Models::Work.create!(id: 1) }
        let(:pid_minter) { -> { 'abc123' } }
        before { test_repository.attach_files_to(work: work, files: file, user: user, pid_minter: pid_minter) }
        it 'will change the file name' do
          test_repository.amend_files_metadata(work: work, user: user, metadata: { 'abc123' => { 'name' => 'Howdy' } })
          expect(Models::Attachment.find('abc123').name).to eq('Howdy')
        end
      end

      context '#set_as_representative_attachment' do
        let(:file) { FileUpload.fixture_file_upload('attachments/hello-world.txt') }
        let(:file_name) { "hello-world.txt" }
        let(:user) { User.new(id: 1234) }
        let(:work) { Models::Work.create!(id: '1') }
        let(:pid_minter) { -> { 'abc123' } }
        before { test_repository.attach_files_to(work: work, files: file, user: user, pid_minter: pid_minter) }
        it 'will mark the given attachments as representative in the system' do
          expect { test_repository.set_as_representative_attachment(work: work, pid: pid_minter.call) }.
            to change { Models::Attachment.where(is_representative_file: true).count }.by(1)
        end
        it 'will not mark the given attachments as representative in the system' do
          expect { test_repository.set_as_representative_attachment(work: work, pid: 'bogus') }.
            not_to change { Models::Attachment.where(is_representative_file: true).count }
        end
      end

      context '#apply_access_policies_to' do
        let(:work) { double('Work') }
        let(:user) { double('User') }
        let(:access_policies) { double('AccessPolicies') }
        it 'will mark the given attachments as representative in the system' do
          expect(Services::ApplyAccessPoliciesTo).to receive(:call).with(work: work, user: user, access_policies: access_policies)
          test_repository.apply_access_policies_to(work: work, user: user, access_policies: access_policies)
        end
      end
    end
  end
end
