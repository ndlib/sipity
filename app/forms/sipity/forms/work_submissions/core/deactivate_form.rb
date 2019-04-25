require 'sipity/forms/processing_form'
require 'active_model/validations'
require_relative '../../../forms'
module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Responsible for deactivating a Work.
        class DeactivateForm
          ProcessingForm.configure(
            form_class: self,
            base_class: Models::Work,
            processing_subject_name: :work,
            attribute_names: [:confirm_deactivate],
            template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.confirm_deactivate = attributes[:confirm_deactivate]
            initialize_submission_window!
          end

          include ActiveModel::Validations
          validates :confirm_deactivate, acceptance: { accept: true }
          validates :requested_by, presence: true

          def submit
            return false unless valid?
  # How do we get the "to" status?
            transition_to_status = 'deactivated'
  # how do we route to this?
            # update_entity_processing_state!(entity: work, to: transition_to_status)
            submission_window # return to dashboard
          end


          # TODO: Normalize translation
          def deactivate
            view_context.t('deactivate_work', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
          end

          def verify_deactivation
            view_context.t('deactivate_work', scope: 'sipity/forms.state_advancing_actions.verification.deactivate_work').html_safe
          end

          # @param f SimpleFormBuilder
          #
          # @return String
          def render(f:)
            markup = view_context.content_tag('legend', deactivate)
            markup << f.input(
              :confirm_deactivate,
              as: :boolean,
              inline_label:
              verify_deactivation,
              input_html: { required: 'required' }, # There is no way to add true boolean attributes to simle_form fields.
              label: false,
              wrapper_class: 'checkbox'
            ).html_safe
          end

          private

          def confirm_deactivate=(value)
            @confirm_deactivate = PowerConverter.convert(value, to: :boolean)
          end

          attr_reader :submission_window

          def initialize_submission_window!
            @submission_window = PowerConverter.convert(work, to: :submission_window)
          end

          def view_context
            Draper::ViewContext.current
          end
        end
      end
    end
  end
end
