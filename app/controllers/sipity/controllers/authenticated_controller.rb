module Sipity
  module Controllers
    # For those controllers that require authentication
    class AuthenticatedController < ::ApplicationController
     # Enable profiling for data_admin users

      def authenticate_user!
        authenticated_user = authenticate_with_http_basic do |group_name, group_api_key|
          authorize_group_from_api_key(group_name: group_name, group_api_key: group_api_key)
        end
        if authenticated_user
          @current_user = authenticated_user
        else
          super
        end
      end

      # Required because the authorization layer is firing the current user test prior to the authenticate_user! action filter
      # The end result was that the user for the web request came through as nil in the authorization layer.
      #
      # @todo With Cogitate this will need to be revisited
      def current_user
        super
        current_user_enables_profiler! if profiling_enabled?
        return @current_user if @current_user
        authenticate_user!
        @current_user
      end

      def current_user_enables_mini_profiler!
        return unless @current_user
        return unless Sipity::DataGenerators::WorkTypes::EtdGenerator::DATA_ADMINISTRATORS.include?(current_user.username)
        Rack::MiniProfiler.authorize_request
        return
      end
      private

      # @todo With Cogitate this will need to be revisited
      def authorize_group_from_api_key(group_name:, group_api_key:)
        return false unless group_api_key
        return false unless group_name
        Sipity::Models::Group.find_by(name: group_name, api_key: group_api_key) || false
      end
 
      def profiling_enabled?
        Rails.configuration.use_profiler == true
      end
    end
  end
end
