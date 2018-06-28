module Sipity
  module Exporters
    class BatchIngestExporter
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
          RestClient.put path, myfile: File.new(file, 'rb'), 'X-Api-Token' => Figaro.env.curate_batch_api_key!
        end
      end
    end
  end
end
