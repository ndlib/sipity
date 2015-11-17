module Sipity
  module Controllers
    # The controller for creating works.
    class WorkSubmissionsController < ApplicationController
      class_attribute :response_handler_container
      self.runner_container = Sipity::Runners::WorkSubmissionsRunners
      self.response_handler_container = Sipity::ResponseHandlers::WorkSubmissionHandler

      def query_action
        run_and_respond_with_processing_action(work_id: work_id, attributes: query_or_command_attributes)
      end

      def command_action
        run_and_respond_with_processing_action(work_id: work_id, attributes: query_or_command_attributes)
      end

      def initialize(*args, &block)
        super(*args, &block)
        self.processing_action_composer = ProcessingActionComposer.build_for_controller(controller: self)
      end

      delegate(
        :prepend_processing_action_view_path_with,
        :run_and_respond_with_processing_action,
        to: :processing_action_composer
      )

      attr_accessor :view_object
      helper_method :view_object
      alias_method :model, :view_object
      helper_method :model

      # @TODO - With Cogitate this will need to be revisited
      def authenticate_user!
        authenticate_with_http_basic { |user, password| user_for_etd_ingester(user: user, password: password) } || super
      end

      # @TODO - With Cogitate this will need to be revisited
      def user_for_etd_ingester(user:, password:, group_name: DataGenerators::WorkTypes::EtdGenerator::ETD_INGESTORS, env: Figaro.env)
        return false unless user == group_name
        return false unless password == env.sipity_batch_ingester_access_key!
        Sipity::Models::Group.find_by!(name: group_name)
      end

      private

      attr_accessor :processing_action_composer

      def work_id
        params.require(:work_id)
      end

      def query_or_command_attributes
        params.fetch(:work) { HashWithIndifferentAccess.new }
      end
    end
  end
end
