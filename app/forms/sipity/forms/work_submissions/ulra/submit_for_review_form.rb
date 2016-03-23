require 'sipity/forms/processing_form'
require 'active_model/validations'
require_relative '../../../forms'
module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for submitting the associated entity to the advisor
        # for signoff.
        class SubmitForReviewForm
          ProcessingForm.configure(
            attribute_names: [:agree_to_terms_of_deposit],
            base_class: Models::Work,
            form_class: self,
            processing_subject_name: :work,
            template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.agree_to_terms_of_deposit = attributes[:agree_to_terms_of_deposit]
          end

          include ActiveModel::Validations
          validates :agree_to_terms_of_deposit, acceptance: { accept: true }

          def render(f:)
            markup = view_context.content_tag('legend', deposit_terms_legend)
            markup << view_context.content_tag('article', deposit_terms, class: 'legally-binding-text')
            markup << f.input(
              :agree_to_terms_of_deposit,
              as: :boolean,
              inline_label: deposit_agreement,
              input_html: { required: 'required' }, # There is no way to add true boolean attributes to simle_form fields.
              label: false,
              wrapper_class: 'checkbox'
            ).html_safe
          end

          delegate :submit, to: :processing_action_form

          private

          def deposit_terms_legend
            view_context.t('ulra/submit_for_review', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
          end

          def deposit_terms
            view_context.t('ulra/statement_of_terms', scope: 'sipity/legal.deposit').html_safe
          end

          def deposit_agreement
            view_context.t('agree_to_terms', scope: 'sipity/legal.deposit').html_safe
          end

          def view_context
            Draper::ViewContext.current
          end

          def agree_to_terms_of_deposit=(value)
            @agree_to_terms_of_deposit = PowerConverter.convert_to_boolean(value)
          end
        end
      end
    end
  end
end
