require 'fileutils'

module Sipity
  module Exporters
    class BatchIngestExporter
      # Responsible for writing the content to the given path
      module FileWriter
        def self.call(content:, path:, file_utility: default_file_utility)
          file_utility.mkdir_p(File.dirname(path))
          File.open(path, 'w+') { |handle| handle.puts content }
        end

        def self.default_file_utility
          FileUtils
        end
        private_class_method :default_file_utility
      end
    end
  end
end
