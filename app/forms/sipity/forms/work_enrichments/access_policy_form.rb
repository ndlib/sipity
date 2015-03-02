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
          @accessible_objects ||= repository.accessible_objects(work: work).map { |obj| AccessibleObjectFromPersistence.new(obj) }
        end

        module AccessibleObjectCodes
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
        private_constant :AccessibleObjectCodes

        # Responsible for capturing and validating the accessible object from
        # the user's input.
        class AccessibleObjectFromInput
          include AccessibleObjectCodes
          include ActiveModel::Validations
          include Conversions::ExtractInputDateFromInput

          def initialize(persisted_object, attributes = {})
            @persisted_object = persisted_object
            @access_right_code = attributes[:access_right_code]
            self.release_date = extract_input_date_from_input(:release_date, attributes) { nil }
          end
          attr_reader :access_right_code, :release_date, :persisted_object

          delegate :persisted?, :id, :to_s, to: :persisted_object

          def persisted?
            true
          end

          validates :access_right_code, presence: true, inclusion: { in: :valid_access_right_codes, allow_nil: true }
          validates :release_date, presence: { if: :will_be_under_embargo? }

          private

          def release_date=(value)
            @release_date = value
          end

          def will_be_under_embargo?
            access_right_code == embargo_then_open_access_access_code
          end

          def valid_access_right_codes
            [open_access_access_code, restricted_access_access_code, private_access_access_code, embargo_then_open_access_access_code]
          end
        end

        # Responsible for translating user input into persistence concerns.
        class AccessibleObjectFromPersistence
          include AccessibleObjectCodes
          def initialize(object)
            @object = object
          end
          attr_reader :access_right_code, :release_date
          delegate :persisted?, :id, :to_s, to: :@object
        end
      end
    end
  end
end
