require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module Ulra
        # Responsible for capturing and validating information for research process
        class AssignAwardStatusForm
          ProcessingForm.configure(
            attribute_names: [:is_an_award_winner],
            base_class: Models::Work,
            form_class: self,
            processing_subject_name: :work
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.is_an_award_winner = attributes.fetch(:is_an_award_winner) { is_an_award_winner_from_work }
          end

          POSSIBLE_IS_AN_AWARD_WINNER = %w(Yes No).freeze
          include ActiveModel::Validations
          validates :is_an_award_winner, presence: true, inclusion: { in: POSSIBLE_IS_AN_AWARD_WINNER }

          def possible_is_an_award_winner
            POSSIBLE_IS_AN_AWARD_WINNER
          end

          def submit
            processing_action_form.submit do
              repository.update_work_attribute_values!(work: work, key: 'is_an_award_winner', values: is_an_award_winner)
            end
          end

          private

          # rubocop:disable Style/PredicateName
          def is_an_award_winner_from_work
            repository.work_attribute_values_for(work: work, key: "is_an_award_winner", cardinality: 1)
          end
          # rubocop:enable Style/PredicateName
        end
      end
    end
  end
end
