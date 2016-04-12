require 'sipity/exporters/batch_ingest_exporter/file_writer'

module Sipity
  module Exporters
    class BatchIngestExporter
      # Responsible for writing the given metadata to the correct file.
      module MetadataWriter
        def self.call(metadata:, exporter:)
          path = File.join(exporter.data_directory, "metadata-#{exporter.work_id}.rof")
          content = JSON.dump(metadata)
          FileWriter.call(content: content, path: path)
        end
      end
    end
  end
end
