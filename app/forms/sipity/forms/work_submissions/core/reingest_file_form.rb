require_relative '../../../forms'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Responsible for submitting final step of file replacement, which transitions the state for reingesting
        class ReingestFileForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME,
            attribute_names: [:confirm_reingest]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.confirm_reingest = attributes[:confirm_reingest]
          end

          include ActiveModel::Validations
          validates :confirm_reingest, acceptance: { accept: true }

          # @param f SimpleFormBuilder
          #
          # @return String
          def render(f:)
            markup = view_context.content_tag('legend', legend)
            markup << f.input(
              :confirm_reingest,
              as: :boolean,
              inline_label:
              verify_reingest,
              input_html: { required: 'required' }, # There is no way to add true boolean attributes to simle_form fields.
              label: false,
              wrapper_class: 'checkbox'
            ).html_safe
          end

          def submit
            return false unless valid?
            processing_action_form.submit
          end

          private

          # for header
          def legend
             view_context.t('verify_reingest', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
          end

          # for checkbox description
          def verify_reingest
            view_context.t('i_agree', scope: 'sipity/forms.state_advancing_actions.verification.verify_reingest').html_safe
          end
          
          def confirm_reingest=(value)
            @confirm_reingest = PowerConverter.convert(value, to: :boolean)
          end

          def view_context
            Draper::ViewContext.current
          end
        end
      end
    end
  end
end
