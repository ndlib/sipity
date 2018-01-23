require 'rails_helper'
require 'support/sipity/command_repository_interface'
require 'sipity/services/manage_collaborators'

module Sipity
  module Services
    RSpec.describe ManageCollaborators do
      let(:work) { Models::Work.new(id: 123) }
      let(:repository) { CommandRepositoryInterface.new }
      let(:responsible_for_review?) { false }
      let(:collaborator) do
        Models::Collaborator.new(
          work_id: work.id, responsible_for_review: responsible_for_review?, name: 'Jeremy', role: 'Research Director', netid: 'somebody'
        )
      end

      it 'exposes .assign_collaborators_to as a public API convenience method' do
        expect_any_instance_of(described_class).to receive(:assign_given_collaborators!)
        described_class.assign_collaborators_to(work: work, repository: repository, collaborators: collaborator)
      end

      describe '.manage_collaborators_for' do
        it 'will disassociate from the work (and destroy) collaborators and any associated processing actor not provided' do
          collaborator.save! # Ensuring an association
          collaborator.to_processing_actor # Ensuring a processing actor
          expect do
            expect do
              described_class.manage_collaborators_for(work: work, collaborators: [], repository: repository)
            end.to change { Models::Processing::Actor.count }.by(-1)
          end.to change { Models::Collaborator.count }.by(-1)
        end

        context 'when a collaborator is not responsible_for_review' do
          let(:responsible_for_review?) { false }
          it 'will create a collaborator but not a user nor permission' do
            expect(repository).not_to receive(:grant_permission_for!)
            expect do
              expect do
                described_class.assign_collaborators_to(work: work, collaborators: collaborator, repository: repository)
              end.to change(Models::Collaborator, :count).by(1)
            end.to_not change(User, :count)
          end
        end

        context 'when a collaborator is responsible_for_review' do
          let(:responsible_for_review?) { true }
          it 'will create a collaborator, user, and permission' do
            expect(repository).to receive(:grant_permission_for!).and_call_original
            expect do
              expect do
                described_class.manage_collaborators_for(work: work, collaborators: collaborator, repository: repository)
              end.to change(Models::Collaborator, :count).by(1)
            end.to change(User, :count).by(1)
          end

          it 'will transfer permissioning from the collaborator to the newly assigned user' do
            collaborator.save!
            processing_actor = collaborator.to_processing_actor # Ensuring a processing actor
            expect(processing_actor.reload.proxy_for).to eq(collaborator)
            described_class.manage_collaborators_for(work: work, collaborators: collaborator, repository: repository)

            # As the user is created, we want to transfer any permission from that collaborator to the user.
            expect(processing_actor.reload.proxy_for).to eq(User.last)
          end
        end

        context 'when a collaborator was once responsible for review, but no longer is' do
          before do
            collaborator.responsible_for_review = true
            collaborator.save!
          end
          xit 'will remove permissions from that collaborator' do
            collaborator.responsible_for_review = false
            expect(repository).to receive(:revoke_permission_for!).and_call_original
            described_class.manage_collaborators_for(work: work, collaborators: collaborator, repository: repository)
          end
        end
      end
    end
  end
end
