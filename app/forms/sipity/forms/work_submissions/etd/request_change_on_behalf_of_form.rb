require 'sipity/forms/processing_form'
require 'active_model/validations'
require_relative '../../../forms'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for exposing ability for someone to comment and request
        # changes to the work on behalf of someone else.
        class RequestChangeOnBehalfOfForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, attribute_names: [:comment, :on_behalf_of_collaborator_id],
            template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.comment = attributes[:comment]
            self.on_behalf_of_collaborator_extension = build_collaborator_extension
            self.on_behalf_of_collaborator_id = attributes[:on_behalf_of_collaborator_id]
          end

          delegate(
            :valid_on_behalf_of_collaborators, :on_behalf_of_collaborator, :on_behalf_of_collaborator_id,
            :on_behalf_of_collaborator_id=, :valid_on_behalf_of_collaborator_ids,
            to: :on_behalf_of_collaborator_extension
          )
          private(:on_behalf_of_collaborator_id=)

          include ActiveModel::Validations
          validates :comment, presence: true
          validates :on_behalf_of_collaborator_id, presence: true, inclusion: { in: :valid_on_behalf_of_collaborator_ids }

          # @param f SimpleFormBuilder
          #
          # @return String
          def render(f:)
            markup = view_context.content_tag('legend', comment_legend)
            markup << f.input(:on_behalf_of_collaborator_id, label: signoff_agreement, collection: valid_on_behalf_of_collaborators, value_method: :id)
            markup << f.input(:comment, as: :text, autofocus: true, input_html: { class: 'form-control', required: 'required' })
          end

          def submit
            return false unless valid?
            save
            work
          end

          private

          def comment_legend
            view_context.t("etd/#{processing_action_name}", scope: 'sipity/forms.state_advancing_actions.legend').html_safe
          end

          def signoff_agreement
            view_context.t('i_agree', scope: 'sipity/forms.state_advancing_actions.verification.etd/request_change_on_behalf_of').html_safe
          end
          def view_context
            Draper::ViewContext.current
          end

          attr_accessor :on_behalf_of_collaborator_extension

          def save
            Services::RequestChangesViaCommentService.call(
              form: self, repository: repository, requested_by: requested_by, on_behalf_of: on_behalf_of_collaborator
            )
          end

          def build_collaborator_extension
            Forms::ComposableElements::OnBehalfOfCollaborator.new(form: self, repository: repository)
          end
        end
      end
    end
  end
end
