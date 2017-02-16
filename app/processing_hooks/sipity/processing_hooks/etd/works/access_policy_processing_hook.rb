require 'sipity/conversions/convert_to_work'

module Sipity
  module ProcessingHooks
    module Etd
      module Works
        # Responsible for performing additional behavior when an ETD's AccessPolicy action is taken.
        #
        # - Force OPEN_ACCESS for the given entity.
        #
        # @see Sipity::Models::AccessRight
        module AccessPolicyProcessingHook
          module_function

          # @api private
          # @see Sipity::ProcessingHooks.call for how this is called
          def call(entity:, **_keywords)
            work = Conversions::ConvertToWork.call(entity)

            # Force open access for the given work
            access_right = Models::AccessRight.find_or_initialize_by(entity: work)
            access_right.access_right_code = Models::AccessRight::OPEN_ACCESS
            access_right.save
          end
        end
      end
    end
  end
end
