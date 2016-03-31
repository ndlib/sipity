require 'sipity/conversions/to_rof_hash/work_converters/abstract_converter'
module Sipity
  module Conversions
    module ToRofHash
      module WorkConverters
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
