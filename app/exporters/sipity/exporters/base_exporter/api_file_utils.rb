module Sipity
  module Exporters
    class BaseExporter
      # Overrides file utils to allow for API processing. Returns response.
      module ApiFileUtils
        def self.put_content(path, content = nil)
          RestClient.put path, content, 'X-Api-Token' => Figaro.env.curate_batch_api_key!
        rescue RestClient::Exception => e
          Sentry.capture_exception(e,
            extra: { error: e.http_code,
                     path: path,
                     content: content })
        end

        def self.mkdir_p(*)
          # do nothing
        end

        def self.mv(_from, destination)
          RestClient.post destination, "", 'X-Api-Token' => Figaro.env.curate_batch_api_key!
        rescue RestClient::Exception => e
          Sentry.capture_exception(e,
            extra: { error: e.http_code, path: destination })
        end
      end
    end
  end
end
