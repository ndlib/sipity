require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Exposes a means updating the permanent email address. The permanent email is
        # entered by the ETD author, but is something that sometimes requires updating by the grad school
        class PermanentEmailForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work, attribute_names: [:permanent_email]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            initialize_attributes(attributes)
          end

          include ActiveModel::Validations
          validates :permanent_email, presence: true

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(
                work: work,
                key: Models::AdditionalAttribute::PERMANENT_EMAIL,
                values: permanent_email
              )
            end
          end

          private

          def initialize_attributes(attributes)
            self.permanent_email = attributes.fetch(:permanent_email) { permanent_email_from_work }
          end

          def permanent_email_from_work
            repository.work_attribute_values_for(
              work: work,
              key: Models::AdditionalAttribute::PERMANENT_EMAIL,
              cardinality: 1
            )
          end
        end
      end
    end
  end
end
