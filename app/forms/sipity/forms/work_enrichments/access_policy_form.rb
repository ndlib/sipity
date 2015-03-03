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
        def initialize(attributes = {})
          super
          self.accessible_objects_attributes = attributes.fetch(:accessible_objects_attributes) { {} }
        end

        # Because I am using `#fields_for` for rendering
        def accessible_objects_attributes=(values)
          @accessible_objects_attributes = parse_accessible_objects_attributes(values)
        end
        attr_reader :accessible_objects_attributes

        validate :each_accessible_objects_attributes_are_valid
        validate :at_lease_one_accessible_objects_attributes_entry

        def accessible_objects
          if @accessible_objects_attributes.present?
            @accessible_objects_attributes
          else
            @accessible_objects ||= accessible_objects_from_repository
          end
        end

        private

        def each_accessible_objects_attributes_are_valid
          return true if accessible_objects_attributes.all?(&:valid?)
          errors.add(:accessible_objects_attributes, :invalid)
        end

        def at_lease_one_accessible_objects_attributes_entry
          return true if accessible_objects_attributes.present?
          errors.add(:base, :presence_of_access_policies_for_objects_required)
        end

        def save(requested_by:)
          super do
            repository.apply_access_policies_to(work: work, user: requested_by, access_policies: access_objects_attributes_for_persistence)
          end
        end

        def access_objects_attributes_for_persistence
          accessible_objects.map(&:to_hash)
        end

        def accessible_objects_from_repository
          repository.accessible_objects(work: work).map { |obj| AccessibleObjectFromPersistence.new(obj) }
        end

        def parse_accessible_objects_attributes(values = {})
          from_persistence = accessible_objects_from_repository
          values.map do |(_key, attrs)|
            attributes = attrs.with_indifferent_access
            persisted_object = from_persistence.find { |obj| obj.id.to_s == attributes.fetch('id')  }
            AccessibleObjectFromInput.new(persisted_object, attributes)
          end
        end

        # These are shared elements of the AccessibleObjects (both input and
        # from persistence)
        module AccessibleObjectInterface
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
            Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS
          end

          def to_hash
            {
              entity_id: id.to_s,
              entity_type: entity_type,
              access_right_code: access_right_code,
              release_date: release_date
            }
          end
        end
        private_constant :AccessibleObjectInterface

        # Responsible for capturing and validating the accessible object from
        # the user's input.
        class AccessibleObjectFromInput
          include AccessibleObjectInterface
          include ActiveModel::Validations
          include Conversions::ExtractInputDateFromInput

          def initialize(persisted_object, attributes = {})
            @persisted_object = persisted_object
            @access_right_code = attributes[:access_right_code]
            self.release_date = extract_input_date_from_input(:release_date, attributes) { nil }
          end
          attr_reader :access_right_code, :release_date, :persisted_object
          private :persisted_object

          delegate :persisted?, :entity_type, :to_param, :id, :to_s, to: :persisted_object

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
          include AccessibleObjectInterface
          def initialize(object)
            @object = object
          end
          attr_reader :access_right_code, :release_date
          delegate :persisted?, :id, :to_s, :to_param, to: :@object

          include Conversions::ConvertToPolymorphicType
          def entity_type
            convert_to_polymorphic_type(@object)
          end
        end
      end
    end
  end
end
