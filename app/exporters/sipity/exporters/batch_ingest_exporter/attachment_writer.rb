module Sipity
  module Exporters
    class BatchIngestExporter
      # Responsible for writing the specific files that should be written to the batch ingest.
      class AttachmentWriter
        # @api public
        def self.call(work:, exporter:, **keywords)
          new(work: work, exporter: exporter, **keywords).call
        end

        def initialize(work:, exporter:, work_to_attachments_converter: default_work_to_attachments_converter)
          self.work = work
          self.exporter = exporter
          self.work_to_attachments_converter = work_to_attachments_converter
          self.attachments = work_to_attachments_converter.call(work: work)
        end

        def call
          path = File.join(exporter.data_directory, "attachments-#{exporter.work_id}.json")
          content = attachments.to_json
          exporter.file_writer.call(content: content, path: path)
        end

        private

        attr_accessor :work, :exporter, :attachments
        attr_accessor :work_to_attachments_converter

        def default_work_to_attachments_converter
          Conversions::ToRof::WorkConverter.method(:attachments_for)
        end
      end
    end
  end
end
