require 'sipity/exporters/batch_ingest_exporter/file_writer'
module Sipity
  module Exporters
    class BatchIngestExporter
      # Adds a list of URLs to the WEBHOOK file that are called during the batch
      # ingest process.
      module WebhookWriter
        module_function

        def call(exporter:)
          FileWriter.call(content: callback_url(work_id: exporter.work_id), path: target_path(data_directory: exporter.data_directory))
        end

        def target_path(data_directory:)
          File.join(data_directory, 'WEBHOOK')
        end
        private_class_method :target_path

        def callback_url(work_id:)
          authorization_credentials = "#{Sipity::Models::Group::BATCH_INGESTORS}:#{Figaro.env.sipity_batch_ingester_access_key!}"
          File.join(
            "#{Figaro.env.protocol!}://#{authorization_credentials}@#{Figaro.env.domain_name!}",
            "/work_submissions/#{work_id}/callback/ingest_completed.json"
          )
        end
        private_class_method :callback_url
      end
    end
  end
end
