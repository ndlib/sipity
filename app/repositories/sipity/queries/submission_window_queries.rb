module Sipity
  module Queries
    # Queries related to SubmissionWindows.
    module SubmissionWindowQueries
      def find_submission_window_by(slug:, work_area:)
        work_area = PowerConverter.convert(work_area, to: :work_area)
        Models::SubmissionWindow.find_by!(slug: slug, work_area_id: work_area.id)
      end

      def submission_window_names_for_select_within_work_area(work_area:)
        work_area = PowerConverter.convert(work_area, to: :work_area)
        Models::SubmissionWindow.order(:slug).where(work_area_id: work_area.id).pluck(:slug)
      end

      # @api public
      #
      # @param work_area [#to_work_area]
      # @param as_of [Time]
      # @return ActiveRecord::Relation records from Models::SubmissionWindow
      #
      ## @note This query shares logic with OpenForStartingSubmissionsValidator#validate_each
      #
      # @see OpenForStartingSubmissionsValidator
      def find_open_submission_windows_by(work_area:, as_of: Time.zone.now)
        work_area = PowerConverter.convert(work_area, to: :work_area)
        submission_windows = Models::SubmissionWindow.arel_table
        Models::SubmissionWindow.order(:slug).where(work_area_id: work_area.id).where(
          submission_windows[:open_for_starting_submissions_at].lteq(as_of).and(
            submission_windows[:closed_for_starting_submissions_at].eq(nil).or(
              submission_windows[:closed_for_starting_submissions_at].gt(as_of)
            )
          )
        )
      end

      def build_submission_window_processing_action_form(submission_window:, processing_action_name:, **keywords)
        # Leveraging an obvious inflection point, namely each work area may well
        # have its own form module.
        Forms::SubmissionWindows.build_the_form(
          submission_window: submission_window,
          processing_action_name: processing_action_name,
          repository: self,
          **keywords
        )
      end
    end
  end
end
