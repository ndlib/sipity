require 'fileutils'
module Sipity
  module Exporters
    class BatchIngestExporter
      # The batch ingest process is triggered by file operations. When the data
      # preparation is complete its containing directory is moved to the "queue"
      # directory. This module manages moving the data.
      module DirectoryMover
        module_function

        DEFAULT_DESTINATION_PATH = Figaro.env.curate_batch_queue_mount_path!

        def call(exporter:, destination_path: DEFAULT_DESTINATION_PATH, file_utility: default_file_utility)
          prepare_destination(path: destination_path, file_utility: file_utility)
          move_files(source: exporter.data_directory, destination: destination_path, file_utility: file_utility)
        end

        def prepare_destination(path:, file_utility: default_file_utility)
          file_utility.mkdir_p(path)
        end
        private_class_method :prepare_destination

        def move_files(source:, destination:, file_utility: default_file_utility)
          file_utility.mv(source, File.join(destination, '/'))
        end
        private_class_method :move_files

        def default_file_utility
          FileUtils
        end
        private_class_method :default_file_utility
      end
    end
  end
end
