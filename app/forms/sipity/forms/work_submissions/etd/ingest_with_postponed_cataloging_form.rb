require_relative '../../../forms'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Responsible for submitting the final Grad School approval and also mark for ingest with future cataloging date.
        class IngestWithPostponedCatalogingForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, attribute_names: :agree_to_signoff, processing_subject_name: :work,
            template: Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME
          )

          include Conversions::ExtractInputDateFromInput
          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.agree_to_signoff = attributes[:agree_to_signoff]
            self.scheduled_time = extract_input_date_from_input(:scheduled_time, attributes) { scheduled_time_from_work }
          end

          include ActiveModel::Validations
          validates :agree_to_signoff, acceptance: { accept: true }
          validates :scheduled_time, presence: true

          attr_reader :scheduled_time, :reason

          # @param f SimpleFormBuilder
          #
          # @return String
          def render(f:)
            markup = view_context.content_tag('legend', legend)
            markup << add_scheduled_time(f: f)
            markup << add_agree_to_signoff(f: f)
          end

          def add_scheduled_time(f:)
            f.input(:scheduled_time, as: :date, input_html: { value: work.access_right_transition_date }).html_safe
          end

          def add_agree_to_signoff(f:)
            f.input(
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
            view_context.t('etd/ingest_with_postponed_cataloging', scope: 'sipity/forms.state_advancing_actions.legend').html_safe
          end

          def signoff_agreement
            view_context.t(
              'i_agree', scope: 'sipity/forms.state_advancing_actions.verification.etd/ingest_with_postponed_cataloging'
            ).html_safe
          end

          def submit
            processing_action_form.submit do
              create_scheduled_action_if_applicable
            end
          end

          def create_scheduled_action_if_applicable
            repository.create_scheduled_action(
              work: work,
              scheduled_time: scheduled_time,
              reason: Sipity::Models::Processing::AdministrativeScheduledAction::NOTIFY_CATALOGING_REASON
            )
          end

          def scheduled_time_from_work
            repository.scheduled_time_from_work(
              work: work,
              reason: Sipity::Models::Processing::AdministrativeScheduledAction::NOTIFY_CATALOGING_REASON
            )
          end

          include Conversions::ConvertToDate
          def scheduled_time=(value)
            @scheduled_time = convert_to_date(value) { nil }
          end

          def agree_to_signoff=(value)
            @agree_to_signoff = PowerConverter.convert(value, to: :boolean)
          end

          private

          def view_context
            Draper::ViewContext.current
          end
        end
      end
    end
  end
end
