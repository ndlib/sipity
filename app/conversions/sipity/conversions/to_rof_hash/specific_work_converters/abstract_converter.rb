module Sipity
  module Conversions
    module ToRofHash
      module SpecificWorkConverters
        # Responsible for defining the interface for the specific converters
        class AbstractConverter
          def initialize(work:, repository:)
            self.work = work
            self.repository = repository
          end

          private

          attr_accessor :work, :repository

          public

          def metadata
            raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          end

          def rels_ext
            raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          end

          def af_model
            raise NotImplementedError, "Expected #{self.class} to implement ##{__method__}"
          end

          private

          # @todo Optimize round trips to the database concerning the additional attributes
          def fetch_attribute_values(key:)
            repository.work_attribute_values_for(work: work, key: key)
          end
        end
        private_constant :AbstractConverter
      end
    end
  end
end
