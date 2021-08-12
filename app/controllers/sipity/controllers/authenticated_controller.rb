module Sipity
  module Controllers
    # For those controllers that require authentication
    class AuthenticatedController < ::ApplicationController
     before_action  :enable_profiling
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
        if @current_user
          return @current_user
        end

        authenticate_user!
        @current_user
      end

      private

      # @todo With Cogitate this will need to be revisited
      def authorize_group_from_api_key(group_name:, group_api_key:)
        return false unless group_api_key
        return false unless group_name
        Sipity::Models::Group.find_by(name: group_name, api_key: group_api_key) || false
      end
       
      def enable_profiling
        return false unless profiling_enabled?
        return false unless current_user && is_profiler_user?(user: current_user.username)
        Rack::MiniProfiler.authorize_request
      end
 
      def profiling_enabled?
        Rails.configuration.use_profiler == true
      end
 
      def is_profiler_user?(user:)
        Rails.configuration.profiler_users.include?(user)
      end
    end
  end
end
