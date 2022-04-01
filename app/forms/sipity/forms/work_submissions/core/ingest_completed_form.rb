require_relative '../../../forms'
require 'sipity/conversions/convert_to_permanent_uri'
require 'sipity/exceptions'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Responsible for handling the WEBHOOK callbacks from the ETD
        # batch ingest process.
        #
        # The associated `processing_action_name` is a misnomer; Yes,
        # it handles the "ingest_completed" action.  But that action
        # may be better named "handle_batch_ingest_response".
        #
        # What is happening in this form is that we are handling the
        # WEBHOOK payload sent by the batch ingester.  The {#submit}
        # method highlights this.
        #
        # @see https://github.com/ndlib/curatend-batch/blob/master/webhook.md
        class IngestCompletedForm
          # The batch process completed successfully, so we'll take
          # the Sipity action thatadvances the state (e.g. "ingest_completed")
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
              processing_action_form.submit do
                remove_after_ingest_enrichment_action_registration
                create_a_redirect
              end
            end
          end

          private

          include Conversions::ConvertToPermanentUri
          def create_a_redirect
            repository.create_redirect_for(work: work, url: convert_to_permanent_uri(work))
          end

          # now that ingest is completed, we remove any prior 'after-ingest' enrichment actions so they can potentially be repeated
          # NOTE: it is definitely not ideal to hardcode the action, but at this point there isn't any better way. If we get more actions of this type, it would be good to tease out a better way
          def remove_after_ingest_enrichment_action_registration
            repository.unregister_action_taken_on_entity_by_anyone(entity: work, action: 'update_file', requested_by: requested_by)
          end

          def register_error
            Sentry.capture_exception(Exceptions::IngestUnableToCompleteError.new,
                                    extra: { message: "Problem encountered in Batch Ingester. Review batch logs.",
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
