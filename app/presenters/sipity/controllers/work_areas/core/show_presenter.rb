require 'active_support/core_ext/array/wrap'
require 'sipity/controllers/visitors/core/work_area_presenter'

module Sipity
  module Controllers
    module WorkAreas
      module Core
        # Responsible for presenting a work area
        class ShowPresenter < Controllers::Visitors::Core::WorkAreaPresenter
          # We're injecting these attributes onto the result set for
          # the works.  And by default that would be no attributes.
          #
          # @see Sipity::Parameters::SearchCriteriaForWorksParameter
          class_attribute :additional_attributes, default: [], instance_writer: false

          def filter_form(dom_class: 'form-inline', method: 'get', &block)
            form_tag(request.path, method: method, class: dom_class, &block)
          end

          def works
            @works ||= repository.find_works_via_search(criteria: search_criteria)
          end

          def paginate_works
            paginate(works)
          end

          private

          def search_criteria
            @search_criteria ||= begin
              Parameters::SearchCriteriaForWorksParameter.new(
                user: current_user,
                processing_state: work_area.processing_state,
                page: work_area.page,
                order: work_area.order,
                repository: repository,
                work_area: work_area,
                q: work_area.q,
                submission_window: work_area.submission_window,
                additional_attributes: additional_attributes
              )
            end
          end
        end
      end
    end
  end
end
