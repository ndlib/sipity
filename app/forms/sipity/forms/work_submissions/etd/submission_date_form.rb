require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Exposes a means updating the submission date. The submission date is
        # something assigned by the system, but is something that sometimes
        # requires editing by the grad school
        #
        # @see Sipity::ProcessingHooks::Etd::Works::SubmitForReviewProcessingHook
        class SubmissionDateForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work, attribute_names: [:submission_date]
          )

          include Conversions::ExtractInputDateFromInput
          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.submission_date = extract_input_date_from_input(:submission_date, attributes) { submission_date_from_work }
          end

          include ActiveModel::Validations
          validates :submission_date, presence: true

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(
                work: work,
                key: Models::AdditionalAttribute::ETD_SUBMISSION_DATE,
                values: submission_date
              )
            end
          end

          include Conversions::ConvertToDate
          def submission_date=(value)
            @submission_date = convert_to_date(value) { nil }
          end

          private

          def submission_date_from_work
            repository.work_attribute_values_for(
              work: work,
              key: Models::AdditionalAttribute::ETD_SUBMISSION_DATE,
              cardinality: 1
            )
          end
        end
      end
    end
  end
end
