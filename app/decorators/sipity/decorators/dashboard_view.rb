require 'sipity/parameters/search_criteria_for_works_parameter'

module Sipity
  module Decorators
    # Responsible for collecting the logic related to rendering a user's
    # dashboard.
    class DashboardView
      def initialize(repository: default_repository, user:, filter: {}, page:)
        self.repository = repository
        self.filter = filter
        self.user = user
        self.page = page || 1
      end

      attr_accessor :repository, :user, :filter, :page
      private :repository=, :user=, :filter=

      def search_path
        view_context.dashboard_path
      end

      def filterable_processing_states
        # TODO: Move this to a repository question; After all don't we want
        # to limit the filter to only objects that are for states in which the
        # user can actually do something (ie see it, alter it, etc)
        Models::Processing::StrategyState.all.order(:name).select(:name).uniq.pluck(:name)
      end

      def works_scope
        @works_scope ||= repository.find_works_via_search(criteria: criteria, repository: repository)
      end

      def works(decorator: WorkDecorator)
        works_scope.map { |work| decorator.new(work) }
      end

      def processing_state
        filter[:processing_state]
      end

      private

      def criteria
        Parameters::SearchCriteriaForWorksParameter.new(
          user: user,
          processing_state: processing_state,
          page: page
        )
      end

      def view_context
        Draper::ViewContext.current
      end

      def default_repository
        QueryRepository.new
      end
    end
  end
end
