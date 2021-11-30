module Sipity
  module Exporters
    class FileReplacementExporter
      # Responsible for loading the specific files that should be written to the batch ingest.
      class AttachmentWriter
        # @api public
        def self.call(work:, exporter:, **keywords)
          new(work: work, exporter: exporter, **keywords).call
        end

        def initialize(work:, exporter:, work_to_attachments_converter: default_work_to_attachments_converter)
          self.work = work
          self.exporter = exporter
          self.work_to_attachments_converter = work_to_attachments_converter
          self.replaced_attachments = work_to_attachments_converter.call(work: work)
        end

        def call
          # for the file replacements exporter, we only want to include the files which have new versions.
          path = File.join(exporter.data_directory, "attachments.json")
          content = replaced_attachments.to_json
          exporter.file_writer.call(content: content, path: path)
        end

        private

        attr_accessor :work, :exporter, :replaced_attachments
        attr_accessor :work_to_attachments_converter

        def default_work_to_attachments_converter
          Conversions::ToRof::WorkConverter.method(:replaced_attachments_for)
        end
      end
    end
  end
end
