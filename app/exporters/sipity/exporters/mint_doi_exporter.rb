module Sipity
  module Exporters
    # Responsible for coordinating minting a doi through the batch ingester.
    # Structure totally dependent on endpoint functionality in the ingester.
    class MintDoiExporter < Sipity::Exporters::BaseExporter
      def ingest_task
        'start-doi-minting'
      end

      def callback_process
        'doi_completed'
      end

      def call
        # initiates a new external process
        job_initiator
        # identify the task being requested
        task_identifier(task_function_name: ingest_task)
        # attach work metadata
        attach_metadata
        # attach callback webhook
        attach_webhook(callback_process: callback_process)
        # complete external process setup
        complete_job
      end
    end
  end
end
