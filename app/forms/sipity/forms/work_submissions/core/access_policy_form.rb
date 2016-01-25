require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        # Exposes a means of assigning an access policy to each of the related
        # items.
        class AccessPolicyForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:copyright, :accessible_objects_attributes, :representative_attachment_id]
          )
          class_attribute :representative_attachment_predicate_name, instance_writer: false
          self.representative_attachment_predicate_name = :all

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.accessible_objects_attributes = attributes.fetch(:accessible_objects_attributes) { {} }
            self.copyright = attributes.fetch(:copyright) { copyright_from_work }
            self.representative_attachment_id = attributes.fetch(:representative_attachment_id) { representative_attachment_id_from_work }
          end

          include ActiveModel::Validations
          validate :each_accessible_objects_attributes_are_valid
          validate :at_lease_one_accessible_objects_attributes_entry
          validates :copyright, presence: true
          validates :requested_by, presence: true
          validates :representative_attachment_id, presence: true, if: :at_least_one_attachment?

          # Because I am using `#fields_for` for rendering
          def accessible_objects_attributes=(values)
            @accessible_objects_attributes = parse_accessible_objects_attributes(values)
          end

          def accessible_objects
            if @accessible_objects_attributes.present?
              @accessible_objects_attributes
            else
              @accessible_objects ||= accessible_objects_from_repository
            end
          end

          def available_copyrights
            repository.get_controlled_vocabulary_entries_for_predicate_name(name: 'copyright')
          end

          def available_representative_attachments
            repository.work_attachments(work: work, predicate_name: representative_attachment_predicate_name)
          end

          def submit
            processing_action_form.submit(requested_by: requested_by) do
              repository.apply_access_policies_to(
                work: work, user: requested_by, access_policies: access_objects_attributes_for_persistence
              )
              repository.update_work_attribute_values!(work: work, key: 'copyright', values: copyright)
              repository.set_as_representative_attachment(work: work, pid: representative_attachment_id)
            end
          end

          private

          def at_least_one_attachment?
            available_representative_attachments.count > 0
          end

          def representative_attachment_id_from_work
            repository.representative_attachment_for(work: work).to_param
          end

          def each_accessible_objects_attributes_are_valid
            return true if accessible_objects_attributes.all?(&:valid?)
            errors.add(:accessible_objects_attributes, :invalid)
            errors.add(:base, :presence_of_access_policies_for_all_objects_required)
          end

          def at_lease_one_accessible_objects_attributes_entry
            return true if accessible_objects_attributes.present?
            errors.add(:base, :presence_of_access_policies_for_objects_required)
          end

          def copyright_from_work
            repository.work_attribute_values_for(work: work, key: 'copyright', cardinality: 1)
          end

          def access_objects_attributes_for_persistence
            accessible_objects.map(&:to_hash)
          end

          def accessible_objects_from_repository
            repository.access_rights_for_accessible_objects_of(work: work, predicate_name: :all)
          end

          def parse_accessible_objects_attributes(values = {})
            from_persistence = accessible_objects_from_repository
            values.map do |(_key, attrs)|
              attributes = attrs.with_indifferent_access
              persisted_object = from_persistence.find { |obj| obj.id.to_s == attributes.fetch('id') }
              AccessibleObjectFromInput.new(persisted_object, attributes)
            end
          end

          # Responsible for capturing and validating the accessible object from
          # the user's input.
          #
          # REVIEW: This is a hot mess! I have this input collaborating with the
          # underlying input.
          class AccessibleObjectFromInput
            include ActiveModel::Validations
            include Conversions::ExtractInputDateFromInput

            def initialize(persisted_object, attributes = {})
              self.persisted_object = persisted_object
              self.access_right_code = attributes[:access_right_code]
              self.release_date = extract_input_date_from_input(:release_date, attributes) { nil }
            end
            attr_reader :release_date, :access_right_code

            delegate :to_param, :id, :accessible_object_type, :to_s, :human_model_name, to: :persisted_object

            def persisted?
              true
            end

            validates :access_right_code, presence: true, inclusion: { in: :valid_access_right_codes, allow_nil: true }
            validates :release_date, presence: { if: :will_be_under_embargo? }

            def to_hash
              {
                entity_id: id.to_s,
                entity_type: entity_type,
                access_right_code: access_right_code,
                release_date: release_date
              }
            end

            include Conversions::ConvertToPolymorphicType
            def entity_type
              # HACK: It would be nice if the possible objects, however the
              # collaboration of the objects related to this form are out of
              # whack.
              if persisted_object.respond_to?(:entity_type)
                persisted_object.entity_type
              else
                convert_to_polymorphic_type(persisted_object)
              end
            end

            private

            attr_accessor :persisted_object
            attr_writer :access_right_code

            include Conversions::ConvertToDate
            def release_date=(value)
              @release_date = keep_user_input_release_date? ? convert_to_date(value) { nil } : nil
            end

            def keep_user_input_release_date?
              # We don't want to obliterate their input just because they didn't
              # give us an access_right_code.
              access_right_code.blank? || will_be_under_embargo?
            end

            def will_be_under_embargo?
              access_right_code == Models::AccessRight::EMBARGO_THEN_OPEN_ACCESS
            end

            def valid_access_right_codes
              Models::AccessRight.valid_access_right_codes
            end
          end
        end
      end
    end
  end
end
