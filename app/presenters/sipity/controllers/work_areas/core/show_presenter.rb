require 'active_support/core_ext/array/wrap'
require 'sipity/controllers/visitors/core/work_area_presenter'

module Sipity
  module Controllers
    module WorkAreas
      module Core
        # Responsible for presenting a work area
        class ShowPresenter < Controllers::Visitors::Core::WorkAreaPresenter
          public def filter_form(dom_class: 'form-inline', method: 'get', &block)
            form_tag(request.path, method: method, class: dom_class, &block)
          end

          public def works
            @works ||= repository.find_works_via_search(criteria: search_criteria)
          end

          public def paginate_works
            paginate(works)
          end

          private def search_criteria
            @search_criteria ||= begin
              Parameters::SearchCriteriaForWorksParameter.new(
                user: current_user, processing_state: work_area.processing_state, page: work_area.page, order: work_area.order,
                repository: repository, work_area: work_area, q: work_area.q, submission_window: work_area.submission_window
              )
            end
          end
        end
      end
    end
  end
end
