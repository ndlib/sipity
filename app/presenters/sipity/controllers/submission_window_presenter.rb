module Sipity
  module Controllers
    # Responsible for presenting a SubmissionWindow
    class SubmissionWindowPresenter < Curly::Presenter
      presents :submission_window

      def initialize(context, options = {})
        # Because controller actions may not cooperate and instead set a
        # :view_object.
        options.stringify_keys!
        options['submission_window'] ||= options['view_object']
        super
        self.processing_actions = compose_processing_actions
      end

      attr_reader :submission_window
      private :submission_window

      delegate :slug, to: :submission_window

      def link
        link_to(submission_window.slug, path)
      end

      def path_to_start_a_submission
        # TODO: This is a hard-coded action name
        submission_window_action_path(
          work_area_slug: submission_window.work_area_slug, submission_window_slug: submission_window.slug,
          processing_action_name: 'start_a_submission'
        )
      end

      def path
        submission_window_path(
          work_area_slug: submission_window.work_area_slug, submission_window_slug: submission_window.slug
        )
      end

      delegate(
        :resourceful_actions, :resourceful_actions?,
        :enrichment_actions, :enrichment_actions?,
        :state_advancing_actions, :state_advancing_actions?,
        to: :processing_actions
      )

      private

      attr_accessor :processing_actions

      def compose_processing_actions
        ComposableElements::ProcessingActionsComposer.new(user: current_user, entity: submission_window)
      end
    end
  end
end
