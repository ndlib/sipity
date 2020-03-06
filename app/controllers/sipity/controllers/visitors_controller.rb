module Sipity
  module Controllers
    # A junk drawer of actions for visitors that have not yet authenticated.
    class VisitorsController < ApplicationController
      class_attribute :response_handler_container
      self.runner_container = Sipity::Runners::VisitorsRunner
      self.response_handler_container = Sipity::ResponseHandlers::WorkAreaHandler

      def work_area
        run_and_respond_with_processing_action(work_area_slug: work_area_slug)
      end

      def initialize(*args, &block)
        super(*args, &block)
        self.processing_action_composer = ProcessingActionComposer.build_for_controller(
          controller: self, processing_action_name: action_name
        )
      end

      def status
        headers['Content-Type'] = 'application/json'
        work = Sipity::Models::Work.includes(:processing_entity).find(work_id)
        json = { id: work.id, status: work.processing_state }
        render json: json
      end

      delegate(
        :prepend_processing_action_view_path_with,
        :run_and_respond_with_processing_action,
        to: :processing_action_composer
      )

      attr_accessor :view_object
      helper_method :view_object
      alias model view_object
      helper_method :model

      private

      attr_accessor :processing_action_composer

      def work_area_slug
        params.require(:work_area_slug)
      end

      def work_id
        params.require(:work_id)
      end
    end
  end
end
