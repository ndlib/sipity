module Sipity
  module Exporters
    class FileReplacementExporter
      # Responsible for loading the specific files that should be written to the batch ingest.
      class AttachmentWriter
        # @api public
        def self.call(work:, exporter:, **keywords)
          new(work: work, exporter: exporter, **keywords).call
        end

        def initialize(work:, exporter:)
          self.work = work
          self.exporter = exporter
        end

        def call
          # for the file replacements exporter, we only want to include the files which have new versions.
          path = File.join(exporter.data_directory, "attachments.json")
          content = replaced_attachments.to_json
          exporter.file_writer.call(content: content, path: path)
        end
      end
    end
  end
end
