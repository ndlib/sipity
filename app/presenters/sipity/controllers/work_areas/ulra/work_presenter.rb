module Sipity
  module Controllers
    module WorkAreas
      module Ulra
        # Responsible for rendering a given work within the context of the Dashboard.
        #
        # @note This could be extracted outside of this namespace
        class WorkPresenter < Sipity::Controllers::WorkAreas::WorkPresenter
          presents :work

          def award_category
            repository.work_attribute_values_for(work: work, key: 'award_category', cardinality: :one)
          end
        end
      end
    end
  end
end
