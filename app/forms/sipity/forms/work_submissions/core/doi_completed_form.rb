require_relative '../../../forms'
require 'sipity/conversions/convert_to_permanent_uri'
require 'sipity/exceptions'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Responsible for handling the WEBHOOK callbacks from the doi minting process.
        #
        # The associated `processing_action_name` is a misnomer; Yes,
        # it handles the "doi_completed" action.
        #
        # What is happening in this form is that we are handling the
        # WEBHOOK payload sent by the batch ingester.  The {#submit}
        # method highlights this.
        #
        # @see https://github.com/ndlib/curatend-batch/blob/master/webhook.md
        class DoiCompletedForm
          # The batch process completed successfully, so we'll take
          # the Sipity action that advances the state (e.g. "doi_completed")
          JOB_STATE_SUCCESS = 'success'.freeze

          # Oops, something in the batch ingester failed.  You're
          # going to need to look to those error logs.
          JOB_STATE_ERROR = 'error'.freeze

          # When we receive this, the batch ingester is saying that
          # it's doing the work.  It's like sending a status update on
          # a yet to be completed project.
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

          # @return Sipity::Models::Work
          def submit
            return false unless valid?
            case job_state
            when JOB_STATE_PROCESSING
              return work
            when JOB_STATE_ERROR
              register_error
              return work
            when JOB_STATE_SUCCESS

              processing_action_form.submit { save_doi_on_work }
            end
          end

          private

          def save_doi_on_work
            repository.update_work_attribute_values!(work: work, key: 'identifier_doi', values: updated_doi)
          end

          def updated_doi
            Figaro.env.doi_shoulder.to_s + '/' + work.to_param.to_s
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
