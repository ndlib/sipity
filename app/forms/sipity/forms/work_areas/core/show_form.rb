require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'sipity/guard_interface_expectation'

module Sipity
  module Forms
    module WorkAreas
      module Core
        # Responsible for "showing" an ETD Work Area.
        class ShowForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::WorkArea, attribute_names: [:processing_states, :order, :page, :q, :submission_window]
          )

          def initialize(work_area:, requested_by:, attributes: {}, **keywords)
            self.work_area = work_area
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.search_criteria_config = keywords.fetch(:search_criteria_config) { default_search_criteria_config }
            self.processing_states = attributes.fetch(:processing_states) { default_processing_states }
            self.submission_window = attributes[:submission_window]
            self.q = attributes[:q]
            self.order = attributes.fetch(:order) { default_order }
            self.page = attributes.fetch(:page) { default_page }
          end

          # @note There is a correlation to the Parameters::SearchCriteriaForWorksParameter
          #   object
          def input_name_for_select_processing_states
            "#{model_name.param_key}[processing_states][]"
          end

          def processing_states_for_select
            repository.processing_state_names_for_select_within_work_area(work_area: work_area)
          end

          # @note There is a correlation to the Parameters::SearchCriteriaForWorksParameter
          #   object
          def input_name_for_select_sort_order
            "#{model_name.param_key}[order]"
          end

          # @note There is a correlation to the Parameters::SearchCriteriaForWorksParameter
          #   object
          def input_name_for_q
            "#{model_name.param_key}[q]"
          end

          # @note There is a correlation to the Parameters::SearchCriteriaForWorksParameter
          #   object
          def input_name_for_selecting_submission_window
            "#{model_name.param_key}[submission_window]"
          end

          def submission_windows_for_select
            repository.submission_window_names_for_select_within_work_area(work_area: work_area)
          end

          include ActiveModel::Validations

          delegate :name, :slug, to: :work_area

          private

          def default_processing_states
            repository.processing_state_names_for_select_within_work_area(work_area: work_area, include_terminal: false)
          end

          delegate :default_order, :default_page, :order_options_for_select, to: :search_criteria_config
          attr_accessor :search_criteria_config

          include GuardInterfaceExpectation
          def work_area=(input)
            guard_interface_expectation!(input, :name, :slug)
            @work_area = input
          end

          def default_search_criteria_config
            Parameters::SearchCriteriaForWorksParameter
          end
        end
      end
    end
  end
end
