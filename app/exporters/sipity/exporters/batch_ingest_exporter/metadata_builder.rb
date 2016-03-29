module Sipity
  module Exporters
    class BatchIngestExporter
      class MetadataBuilder
        # A convenience method for constructing and calling this function.
        def self.call(**keywords, &block)
          new(**keywords, &block).call
        end

        def initialize(**_keywords)
        end

        def call
        end
      end
    end
  end
end
