require_relative '../../../forms'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for submitting final step which is completing cataloging.
        class CatalogingCompleteForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, attribute_names: :agree_to_signoff, processing_subject_name: :work,
            template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.agree_to_signoff = attributes[:agree_to_signoff]
          end

          include ActiveModel::Validations
          validates :agree_to_signoff, acceptance: { accept: true }

          # @param f SimpleFormBuilder
          #
          # @return String
          def render(f:)
            markup = view_context.content_tag('legend', legend)
            markup << f.input(
              :agree_to_signoff,
              as: :boolean,
              inline_label:
              signoff_agreement,
              input_html: { required: 'required' }, # There is no way to add true boolean attributes to simle_form fields.
              label: false,
              wrapper_class: 'checkbox'
            ).html_safe
          end

          def legend
            view_context.t('etd/cataloger_signoff', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
          end

          def signoff_agreement
            view_context.t('i_agree', scope: 'sipity/forms.state_advancing_actions.verification.etd/cataloger_signoff').html_safe
          end

          delegate :submit, to: :processing_action_form

          private

          def agree_to_signoff=(value)
            @agree_to_signoff = PowerConverter.convert_to_boolean(value)
          end

          def view_context
            Draper::ViewContext.current
          end
        end
      end
    end
  end
end
