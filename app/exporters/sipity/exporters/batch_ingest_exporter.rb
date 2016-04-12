require 'fileutils'
require 'sipity/exporters/batch_ingest_exporter/metadata_builder'
require 'sipity/exporters/batch_ingest_exporter/directory_mover'
require 'sipity/exporters/batch_ingest_exporter/webhook_writer'
require 'sipity/exporters/batch_ingest_exporter/metadata_writer'
require 'sipity/exporters/batch_ingest_exporter/attachment_writer'

module Sipity
  module Exporters
    # Responsible for coordinating sending a work through the batch ingest.
    class BatchIngestExporter
      DATA_PATH = Figaro.env.curate_batch_data_mount_path!

      def self.call(work:)
        new(work: work).call
      end

      def initialize(work:, file_utility: default_file_utility)
        self.work = work
        self.file_utility = file_utility
      end

      private

      attr_accessor :file_utility
      attr_writer :work

      def default_file_utility
        FileUtils
      end

      public

      attr_reader :work

      def call
        AttachmentWriter.call(exporter: self, work: work)
        work_metadata = MetadataBuilder.call(exporter: self)
        MetadataWriter.call(metadata: work_metadata, exporter: self)
        WebhookWriter.call(exporter: self)
        DirectoryMover.call(exporter: self)
      end

      # @todo This is not used throughout the submodules; Consider using it as a wrapping concern
      def with_path_to_data_directory
        file_utility.mkdir_p(data_directory)
        yield(data_directory) if block_given?
        data_directory
      end

      def data_directory
        File.join(DATA_PATH, data_directory_basename)
      end

      def data_directory_basename
        "sipity-#{work_id}"
      end

      def queue_pathname
        Pathname.new(File.join(DirectoryMover::DEFAULT_DESTINATION_PATH, data_directory_basename))
      end

      def work_id
        work.to_param
      end
    end
  end
end
