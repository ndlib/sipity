module Sipity
  module Exporters
    # Responsible for coordinating sending a work through the batch ingest.
    class BatchIngestExporter < BaseExporter
      def ingest_task
        'start'
      end

      def callback_process
        'ingest_completed'
      end

      def call
        # initiates a new external process
        job_initiator
        # identify the task being requested
        task_identifier(task_function_name: ingest_task)
        # attach file(s) to the work
        attach_files
        # attach work metadata
        attach_metadata
        # attach callback webhook
        attach_webhook(callback_process: callback_process)
        # complete external process setup
        complete_job
      end

      private

      def attach_files
        AttachmentWriter.call(exporter: self, work: work)
        true
      end
    end
  end
end
