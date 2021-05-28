module Sipity
  module Exporters
    class BaseExporter
      # Overrides file utils to allow for API processing. Returns response.
      module ApiFileUtils
        def self.put_content(path, content = nil)
          RestClient.put path, content, 'X-Api-Token' => Figaro.env.curate_batch_api_key!
        end

        def self.mkdir_p(*)
          # do nothing
        end

        def self.mv(_from, destination)
          RestClient.post destination, "", 'X-Api-Token' => Figaro.env.curate_batch_api_key!
        end

        def self.put_file(path, file)
          # The entire file is loaded into memory prior to sending it.
          content = File.new(file, 'rb').read
          RestClient.put path, content, 'X-Api-Token' => Figaro.env.curate_batch_api_key!
        end
      end
    end
  end
end
