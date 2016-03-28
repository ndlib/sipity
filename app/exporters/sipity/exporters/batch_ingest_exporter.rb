module Sipity
  module Exporters
    class BatchIngestExporter
      def self.call(work:)
        new(work: work).call
      end

      def call
        AttachmentWriter.call(exporter: self)
        work_metadata = MetadataBuilder.call(exporter: self)
        MetadataWriter.call(metadata: work_metadata, exporter: self)
        WebhookWriter.call(exporter: self)
        DirectoryMover.call(exporter: self)
      end

      class AttachmentWriter
      end

      class MetadataBuilder
      end

      class MetadataWriter
      end

      class WebhookWriter
      end

      class DirectoryMover
      end
    end
  end
end
