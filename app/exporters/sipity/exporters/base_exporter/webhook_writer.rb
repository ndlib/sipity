require 'sipity/exporters/base_exporter/file_writer'

module Sipity
  module Exporters
    class BaseExporter
      # Adds a list of URLs to the WEBHOOK file that are called during the
      # exporter process.
      module WebhookWriter
        module_function

        def call(exporter:, process:)
          exporter.file_writer.call(
            content: callback_url(work_id: exporter.work_id, process: process),
            path: target_path(data_directory: exporter.data_directory)
          )
        end

        def target_path(data_directory:)
          File.join(data_directory, 'WEBHOOK')
        end
        private_class_method :target_path

        def callback_url(work_id:, process:, authorization_credentials: default_authorization_credentials)
          URI.encode(
            File.join(
              "#{Figaro.env.protocol!}://#{authorization_credentials}@#{Figaro.env.domain_name!}",
              "/work_submissions/#{work_id}/callback/#{process}.json"
            )
          )
        end

        def default_authorization_credentials
          Models::Group.basic_authorization_string_for!(name: Models::Group::BATCH_INGESTORS)
        end
        private_class_method :default_authorization_credentials
      end
    end
  end
end
