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
          exporter.with_path_to_data_directory do |path|
            write_attachments_to(path: path)
          end
        end

        private

        def write_attachments_to(path:)
          attachments.each do |attachment|
            write_attachment_content_to(path: path, attachment: attachment)
          end
        end

        def write_attachment_content_to(attachment:, path:)
          filename = File.join(path, attachment.to_rof_file_basename)
          attachment.file.to_file(filename)
        end

        attr_accessor :work, :exporter, :attachments
        attr_accessor :work_to_attachments_converter

        def default_work_to_attachments_converter
          Conversions::ToRof::WorkConverter.method(:attachments_for)
        end
      end
    end
  end
end
