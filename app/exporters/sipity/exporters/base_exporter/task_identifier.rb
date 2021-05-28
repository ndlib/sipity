module Sipity
  module Exporters
    class BaseExporter
      # Writes JOB file that tells batch ingest what task function to perform.
      class TaskIdentifier
        def self.call(exporter:, task_function_name:)
          new(exporter: exporter,
              task_function_name: task_function_name)
              .call
        end

        def initialize(exporter:, task_function_name:)
          self.exporter = exporter
          self.task_function_name = task_function_name
        end

        def call
          path = File.join(exporter.data_directory, "JOB")
          content = JSON.dump({ 'Todo' => [task_function_name] })
          exporter.file_writer.call(content: content, path: path)
        end

        attr_accessor :exporter, :task_function_name
      end
    end
  end
end
