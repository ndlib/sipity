module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means of assigning an access policy to each of the related
      # items.
      #
      # TODO: We need to gather up the default data and apply it for form entry.
      #   - When the form is submitted, parse the input and apply the changes
      #     to each of the accessible objects
      #   - When the form is first rendered make sure that the AccessibleObject
      #     has the right values.
      #   - Ensure that the AccessibleObject's date is properly parsed.
      #   - Is there a default we want to "provide" for Embargos (1 year from
      #     now)
      class AccessPolicyForm < Forms::WorkEnrichmentForm
        # Because I am using `#fields_for` for rendering
        attr_writer :accessible_objects_attributes

        def accessible_objects
          repository.accessible_objects(work: work).map { |obj| AccessibleObjectFromPersistence.new(obj) }
        end

        # Responsible for translating user input into persistence concerns.
        class AccessibleObjectFromPersistence
          def initialize(object)
            @object = object
          end
          attr_accessor :access_right_code, :release_date

          delegate :persisted?, :id, :to_s, to: :@object

          def open_access_access_code
            Models::AccessRight::OPEN_ACCESS
          end

          def restricted_access_access_code
            Models::AccessRight::RESTRICTED_ACCESS
          end

          def private_access_access_code
            Models::AccessRight::PRIVATE_ACCESS
          end

          def embargo_then_open_access_access_code
            'embargo_then_open_access'
          end
        end
        private_constant :AccessibleObject
      end
    end
  end
end
