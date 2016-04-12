module Sipity
  module Exporters
    class BatchIngestExporter
      # Responsible for building the metadata array from the given :exporter.
      module MetadataBuilder
        # @api public
        # @return Array<Hash> - An ROF representation of the Work and the Work's attachments
        #
        # A convenience method for constructing and calling this function.
        def self.call(exporter:)
          Sipity::Conversions::ToRof::WorkConverter.call(work: exporter.work)
        end
      end
    end
  end
end
