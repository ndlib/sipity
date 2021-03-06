module Sipity
  module Exporters
    # Responsible for common functions used to coordinate sending a work through an external process.
    # Specific exporters must define:
      # => call
      # => injest_task
      # => callback_process
    # Override individual methods to modify export behavior if necessary.
    class BaseExporter
      JOB_PATH = {
        files: Figaro.env.curate_batch_data_mount_path!,
        api: Figaro.env.curate_batch_api_base_path!
      }.freeze
      FILES_PATH = {
        files: Figaro.env.curate_batch_data_mount_path!,
        api: 'files'
      }.freeze
      DESTINATION_PATH = {
        files: Figaro.env.curate_batch_queue_mount_path!,
        api: 'queue'
      }.freeze

      def self.call(work:)
        new(work: work).call
      end

      # determining the file utility is dependent on the ingest method. At the point where
      # we set the default file utility, we do not yet have an ingest method, so this
      # method needs to rely on the default ingest method. This means that any time you
      # want to use other than the default file_utility or default_ingest_method, you should
      # pass in both.
      def initialize(work:,
                     file_utility: default_file_utility,
                     ingest_method: default_ingest_method)
        self.work = work
        self.ingest_method = ingest_method
        self.file_utility = file_utility
      end

      private

      attr_writer :work, :file_utility, :ingest_method

      def ingest_method=(value)
        raise "Unexpected ingest_method #{value.inspect}" if value != :api && value != :files
        @ingest_method = value
      end

      def default_ingest_method
        :api
      end

      def default_file_utility
        case default_ingest_method
        when :files
          FileUtils
        when :api
          ApiFileUtils
        end
      end

      def job_initiator
        JobInitiator.call(exporter: self)
        true
      end

      def task_identifier(task_function_name:)
        TaskIdentifier.call(exporter: self, task_function_name: task_function_name)
        true
      end

      def attach_metadata
        work_metadata = MetadataBuilder.call(exporter: self)
        MetadataWriter.call(metadata: work_metadata, exporter: self)
        true
      end

      def attach_webhook(callback_process:)
        WebhookWriter.call(exporter: self, process: callback_process)
      end

      def complete_job
        DirectoryMover.call(exporter: self)
      end

      public

      attr_reader :work, :ingest_method, :file_utility

      # Exporters inheriting from base exporter must implement this method.
      def call
        raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
      end

      def job_directory
        File.join(JOB_PATH.fetch(ingest_method), data_directory_basename)
      end

      def data_directory
        case ingest_method
        when :files
          job_directory
        when :api
          File.join(job_directory, FILES_PATH.fetch(ingest_method))
        end
      end

      def with_path_to_data_directory
        file_utility.mkdir_p(data_directory)
        yield(data_directory) if block_given?
        data_directory
      end

      def data_directory_basename
        "sipity-#{work_id}"
      end

      def destination_pathname
        case ingest_method
        when :files
          DESTINATION_PATH.fetch(ingest_method)
        when :api
          File.join(job_directory, DESTINATION_PATH.fetch(ingest_method))
        end
      end

      def work_id
        work.to_param
      end

      def file_writer
        case ingest_method
        when :files
          FileWriter
        when :api
          ApiFileWriter
        end
      end
    end
  end
end
