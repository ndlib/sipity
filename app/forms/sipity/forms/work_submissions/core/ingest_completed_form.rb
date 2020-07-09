require_relative '../../../forms'
require 'sipity/conversions/convert_to_permanent_uri'
require 'sipity/exceptions'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Responsible for calling the ETD Ingester
        class IngestCompletedForm
          # @see https://github.com/ndlib/curatend-batch/blob/master/webhook.md
          JOB_STATE_SUCCESS = 'success'.freeze
          JOB_STATE_ERROR = 'error'.freeze
          JOB_STATE_PROCESSING = 'processing'.freeze

          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work, attribute_names: [:job_state]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.job_state = attributes.fetch(:job_state, nil)
          end

          include ActiveModel::Validations
          validates :job_state, inclusion: { in: [JOB_STATE_SUCCESS, JOB_STATE_ERROR, JOB_STATE_PROCESSING] }

          def submit
            return false unless valid?
            case job_state
            when JOB_STATE_PROCESSING
              return true
            when JOB_STATE_ERROR
              register_error
              return true
            when JOB_STATE_SUCCESS
              processing_action_form.submit { create_a_redirect }
            end
          end

          private

          include Conversions::ConvertToPermanentUri
          def create_a_redirect
            repository.create_redirect_for(work: work, url: convert_to_permanent_uri(work))
          end

          def register_error
            Raven.capture_exception("#{Exceptions::IngestUnableToCompleteError}: Problem encountered in Batch Ingester. Review batch logs.",
                                    extra: { error_class: Exceptions::IngestUnableToCompleteError,
                                             work_id: work.to_param,
                                             work_type: PowerConverter.convert(work, to: :polymorphic_type),
                                             job_state: job_state,
                                             processing_action_name: processing_action_name })
          end
        end
      end
    end
  end
end
