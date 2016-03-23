require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for capturing and validating information for publisher information
        class PublisherInformationForm
          ProcessingForm.configure(
            attribute_names: [:publication_name, :publication_status_of_submission, :submitted_for_publication],
            base_class: Models::Work,
            form_class: self,
            processing_subject_name: :work
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.publication_name = attributes.fetch(:publication_name) { publication_name_from_work }
            self.publication_status_of_submission = attributes.fetch(:publication_status_of_submission) do
              publication_status_of_submission_from_work
            end
            self.submitted_for_publication = attributes.fetch(:submitted_for_publication) { submitted_for_publication_from_work }
          end

          include ActiveModel::Validations
          include Hydra::Validations
          validates :publication_name, presence: { if: :publication_name_required? }
          validates(
            :publication_status_of_submission,
            inclusion: { in: :possible_publication_status_of_submission, if: :submitted_for_publication? }
          )

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'publication_name', values: publication_name)
              repository.update_work_attribute_values!(work: work, key: 'submitted_for_publication', values: submitted_for_publication)
              repository.update_work_attribute_values!(
                work: work, key: 'publication_status_of_submission', values: publication_status_of_submission
              )
            end
          end

          POSSIBLE_PUBLICATION_STATUS_OF_SUBMISSION = ['Accepted'.freeze, 'Not Accepted'.freeze, 'Under Review'.freeze].freeze

          def possible_publication_status_of_submission
            POSSIBLE_PUBLICATION_STATUS_OF_SUBMISSION
          end

          def publication_name_required?
            return false unless publication_status_of_submission.present?
            return false if publication_status_of_submission == 'Not Accepted'
            true
          end

          alias submitted_for_publication? submitted_for_publication

          private

          def publication_name_from_work
            Array.wrap(repository.work_attribute_values_for(work: work, key: 'publication_name', cardinality: :many))
          end

          def publication_status_of_submission_from_work
            repository.work_attribute_values_for(work: work, key: 'publication_status_of_submission', cardinality: 1)
          end

          def submitted_for_publication_from_work
            repository.work_attribute_values_for(work: work, key: 'submitted_for_publication', cardinality: 1)
          end

          def submitted_for_publication=(input)
            @submitted_for_publication = PowerConverter.convert(input, to: :boolean)
          end
        end
      end
    end
  end
end
