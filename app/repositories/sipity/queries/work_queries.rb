module Sipity
  module Queries
    # Queries
    module WorkQueries
      def find_work_by(id:)
        Models::Work.includes(:processing_entity, work_submission: [:work_area, :submission_window]).find(id)
      end

      def build_dashboard_view(user:, filter: {}, repository: self, page:)
        Decorators::DashboardView.new(repository: repository, user: user, filter: filter, page: page)
      end

      # TODO: Rename this method; Keeping it separate for now.
      def build_work_submission_processing_action_form(work:, processing_action_name:, **keywords)
        # Leveraging an obvious inflection point, namely each work area may well
        # have its own form module.
        Forms::WorkSubmissions.build_the_form(
          work: work,
          processing_action_name: processing_action_name,
          repository: self,
          **keywords
        )
      end

      # @param criteria [Sipity::Parameters::SearchCriteriaForWorksParameter]
      #
      # @return [ActiveModel::Relation<Sipity::Models::Work>]
      def find_works_via_search(criteria:, repository: self)
        scope = repository.scope_proxied_objects_for_the_user_and_proxy_for_type(criteria: criteria)
        apply_work_area_filter_to(scope: scope, criteria: criteria)
      end

      def apply_work_area_filter_to(scope:, criteria:)
        return scope unless criteria.work_area
        work_submissions = Models::WorkSubmission.arel_table
        work_area = PowerConverter.convert(criteria.work_area, to: :work_area)
        scope.where(
          Models::Work.arel_table[:id].in(
            work_submissions.project(work_submissions[:work_id]).where(work_submissions[:work_area_id].eq(work_area.id))
          )
        )
      end
      private :apply_work_area_filter_to

      def work_access_right_code(work:)
        work.access_right.access_right_code
      end
    end
  end
end
