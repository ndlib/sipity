require 'curly/presenter'

module Sipity
  module Controllers
    module WorkAreas
      # Responsible for rendering the form for filtering out the various
      # processing actions.
      class FilterFormPresenter < Curly::Presenter
        presents :work_area

        def select_tag_for_processing_state
          select_tag(
            work_area.input_name_for_select_processing_state,
            options_from_collection_for_select(
              work_area.processing_states_for_select, :to_s, :humanize, work_area.processing_state
            ), multiple: true, prompt: 'All states', class: 'form-control'
          ).html_safe
        end

        def select_tag_for_submission_window
          select_tag(
            work_area.input_name_for_selecting_submission_window,
            options_from_collection_for_select(
              work_area.submission_windows_for_select, :to_s, :humanize, work_area.submission_window
            ), include_blank: true, class: 'form-control'
          ).html_safe
        end

        def select_tag_for_sort_order
          select_tag(
            work_area.input_name_for_select_sort_order,
            options_from_collection_for_select(
              work_area.order_options_for_select, :to_s, :humanize, work_area.order
            ), class: 'form-control'
          ).html_safe
        end

        def q_tag
          text_field_tag(
            work_area.input_name_for_q,
            work_area.q,
            placeholder: 'Search for…', class: 'form-control'
          )
        end

        def submit_button(dom_class: 'btn btn-primary', name: 'Go')
          submit_tag(name, class: dom_class)
        end

        private

        attr_reader :work_area
      end
    end
  end
end
