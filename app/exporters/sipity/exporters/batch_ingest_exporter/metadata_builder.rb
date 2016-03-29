module Sipity
  module Exporters
    class BatchIngestExporter
      # Responsible for building the metadata array from the given :exporter.
      class MetadataBuilder
        # @api public
        # @return Array<Hash> - An ROF representation of the Work and the Work's attachments
        #
        # A convenience method for constructing and calling this function.
        def self.call(exporter:, &block)
          new(exporter: exporter, &block).call
        end

        def initialize(exporter:)
          self.exporter = exporter
        end

        extend Forwardable
        def_delegator :exporter, :work

        # @return Array<Hash>
        def call
          # Instead of mutating an instance variable, return a new value after
          # each call
          [to_rof_hash(object: work)] + work.attachments.map do |attachment|
            to_rof_hash(object: attachment)
          end
        end

        private

        attr_accessor :exporter

        def to_rof_hash(object:)
          PowerConverter.convert(object, to: :rof_hash)
        end
      end
    end
  end
end
