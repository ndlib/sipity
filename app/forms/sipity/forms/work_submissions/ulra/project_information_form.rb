require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for creating a new work within the ULRA work area.
        # What goes into this is more complicated that the entity might allow.
        class ProjectInformationForm
          ProcessingForm.configure(
            attribute_names: [:title, :award_category, :course_name, :course_number],
            base_class: Models::Work,
            form_class: self,
            processing_subject_name: :work
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            initialize_attributes(attributes)
          end

          def award_categories_for_select
            repository.get_controlled_vocabulary_values_for_predicate_name(name: 'award_category')
          end

          include ActiveModel::Validations
          validates :title, presence: true
          validates :award_category, presence: true, inclusion: { in: :award_categories_for_select }
          validates :course_name, presence: true
          validates :course_number, presence: true
          validates :requested_by, presence: true

          def submit
            processing_action_form.submit do
              repository.update_work_title!(work: work, title: title)
              ['course_name', 'course_number', 'award_category'].each do |predicate_name|
                repository.update_work_attribute_values!(work: work, key: predicate_name, values: send(predicate_name))
              end
            end
          end

          private

          def initialize_attributes(attributes)
            self.title = attributes.fetch(:title) { work.title }
            [
              [:course_name, 1], [:course_number, 1], [:award_category, 1]
            ].each do |attribute_name, cardinality|
              value = attributes.fetch(attribute_name) do
                repository.work_attribute_values_for(work: work, key: attribute_name.to_s, cardinality: cardinality)
              end
              send("#{attribute_name}=", value)
            end
          end

          def default_repository
            CommandRepository.new
          end
        end
      end
    end
  end
end
