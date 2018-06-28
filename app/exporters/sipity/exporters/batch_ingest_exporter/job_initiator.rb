require 'fileutils'
module Sipity
  module Exporters
    class BatchIngestExporter
      # Responsible for performing the appropriate action to initiate the ingest job.
      module JobInitiator
        module_function

        def call(exporter:, destination_path: exporter.job_directory, file_utility: exporter.file_utility)
          prepare_destination(path: destination_path, file_utility: file_utility, ingest_method: exporter.ingest_method)
        end

        def prepare_destination(path:, file_utility:, ingest_method:)
          case ingest_method
          when :files
            file_utility.mkdir_p(path)
          when :api
            file_utility.put_content(path)
          end
        end
        private_class_method :prepare_destination
      end
    end
  end
end
