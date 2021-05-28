module Sipity
  module Exporters
    class BaseExporter
      # The batch ingest process is triggered by file operations. When the data
      # preparation is complete its containing directory is moved to the "queue"
      # directory. This module manages moving the data.
      module DirectoryMover
        module_function

        def call(exporter:, file_utility: exporter.file_utility)
          destination = exporter.destination_pathname
          prepare_destination(path: destination, file_utility: file_utility)
          move_files(source: exporter.job_directory, destination: destination, file_utility: file_utility)
        end

        def prepare_destination(path:, file_utility:)
          file_utility.mkdir_p(path)
        end
        private_class_method :prepare_destination

        def move_files(source:, destination:, file_utility:)
          file_utility.mv(source, destination)
        end
        private_class_method :move_files
      end
    end
  end
end
