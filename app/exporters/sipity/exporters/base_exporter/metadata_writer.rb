module Sipity
  module Exporters
    class BaseExporter
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
          exporter.file_writer.call(content: content, path: path)
        end

        attr_accessor :exporter, :metadata
      end
    end
  end
end
