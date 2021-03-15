module Sipity
  module Exporters
    class BaseExporter
      # Responsible for writing the content via the API call
      module ApiFileWriter
        def self.call(content:, path:, file_utility: default_file_utility)
          file_utility.put_content(path, content)
        end

        def self.default_file_utility
          ApiFileUtils
        end
        private_class_method :default_file_utility
      end
    end
  end
end
