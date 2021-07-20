require "rails_helper"
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/etd/request_change_on_behalf_of_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe RequestChangeOnBehalfOfForm do
          let(:processing_entity) { Models::Processing::Entity.new(strategy_id: 1) }
          let(:work) { double('Work', to_processing_entity: processing_entity) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          subject { described_class.new(keywords) }

          before do
            allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
              to receive(:valid_on_behalf_of_collaborator_ids).and_return([someone.id])
            allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
              to receive(:valid_on_behalf_of_collaborators).and_return([someone])
            allow_any_instance_of(Forms::ComposableElements::OnBehalfOfCollaborator).
              to receive(:on_behalf_of_collaborator).and_return(someone)
          end

          let(:someone) { double(id: 'one') }

          context '#render' do
            let(:f) { double }

            it 'will render HTML safe comment textarea and comment selection box' do
              input_label = "<span class=\"translation_missing\" title=\"translation missing: en.sipity/forms.state_advancing_actions.verification.etd/request_change_on_behalf_of.i_agree\">I Agree</span>"
              output_label = "<span class=\"translation_missing\" title=\"translation missing: en.sipity/forms.state_advancing_actions.legend.etd/request_change_on_behalf_of\">Etd/Signoff On Behalf Of</span>"

              expect(f).to receive(:input).with(:comment, hash_including(as: :text))
              expect(f).to receive(:input).with(:on_behalf_of_collaborator_id, label: input_label, collection: [someone], value_method: :id).
                and_return("<legend>" + output_label + "</legend>" + "<input />")
              subject.render(f: f)
            end
          end

          its(:comment_legend) { is_expected.to be_html_safe }
          its(:template) { is_expected.to eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          context 'validations' do
            it 'will require a comment' do
              subject = described_class.new(keywords.merge(attributes: { comment: nil }))
              subject.valid?
              expect(subject.errors[:comment]).to be_present
            end

            it 'will require an on_behalf_of_collaborator_id' do
              subject = described_class.new(keywords.merge(attributes: { on_behalf_of_collaborator_id: nil }))
              subject.valid?
              expect(subject.errors[:on_behalf_of_collaborator_id]).to be_present
            end

            it 'will requires a valid on_behalf_of_collaborator_id' do
              subject = described_class.new(keywords.merge(attributes: { on_behalf_of_collaborator_id: someone.id * 2 }))
              subject.valid?
              expect(subject.errors[:on_behalf_of_collaborator_id]).to be_present
            end
          end

          context 'with valid data' do
            subject do
              described_class.new(keywords.merge(attributes: { comment: 'Comments!', on_behalf_of_collaborator_id: someone.id }))
            end
            let(:a_processing_comment) { double }
            before do
              expect(subject).to receive(:valid?).and_return(true)
            end

            it 'will delegate to Services::RequestChangesViaCommentService' do
              expect(Services::RequestChangesViaCommentService).to receive(:call)
              expect(subject.submit).to eq(work)
            end
          end

          context 'with invalid data' do
            subject { described_class.new(keywords) }
            before { expect(subject).to receive(:valid?).and_return(false) }

            it 'will not call Services::RequestChangesViaCommentService' do
              expect(Services::RequestChangesViaCommentService).to_not receive(:call)
              expect(subject.submit).to eq(false)
            end
          end
        end
      end
    end
  end
end
