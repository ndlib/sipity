require 'sipity/exporters/batch_ingest_exporter/file_writer'
require 'sipity/exporters/batch_ingest_exporter/api_file_writer'

module Sipity
  module Exporters
    class BatchIngestExporter
      # Responsible for writing the given metadata to the correct file.
      class MetadataWriter
        # @api public
        def self.call(metadata:, exporter:)
          new(exporter: exporter, metadata: metadata).call
        end

        def initialize(exporter:, metadata:)
          self.exporter = exporter
          self.metadata = metadata
        end

        def call
          path = File.join(exporter.data_directory, "metadata-#{exporter.work_id}.rof")
          content = JSON.dump(metadata)
          file_writer.call(content: content, path: path)
        end

        private

        attr_accessor :exporter, :metadata

        def file_writer
          case exporter.ingest_method
          when :files
            FileWriter
          when :api
            ApiFileWriter
          end
        end
      end
    end
  end
end
