require 'sipity/conversions/to_rof_hash/specific_work_converters/abstract_converter'
module Sipity
  module Conversions
    module ToRofHash
      module SpecificWorkConverters
        class UlraSeniorThesisConverter < AbstractConverter
          def af_model
            'SeniorThesis'
          end
        end

        class UlraDocumentConverter < AbstractConverter
          def af_model
            'Document'
          end
        end
      end
    end
  end
end
