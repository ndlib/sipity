require 'active_support/core_ext/array/wrap'

require 'hesburgh/lib/controller_with_runner'
require 'sipity/query_repository'
require 'sipity/command_repository'

# The foundational controller for this application
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Hesburgh::Lib::ControllerWithRunner
  before_action :filter_notify
  before_action :store_previous_path_if_applicable
  # Enable profiling for data_admin users
  before_action :current_user_enables_mini_profiler

  force_ssl if: :ssl_configured?

  # So you can easily invoke the public repository of Sipity.
  # It is the repository that indicates what the application can and is doing.
  def repository
    case request.request_method
    when "POST", "PATCH", "DELETE", "UPDATE"
      Sipity::CommandRepository.new
    else
      Sipity::QueryRepository.new
    end
  end
  helper_method :repository

  private

  def current_user_enables_mini_profiler(current_user:)
    return false unless current_user
    return false unless Rails.configuration.use_profiler && Sipity::DataGenerators::WorkTypes::EtdGenerator::DATA_ADMINISTRATORS.include?(current_user.username)
    Rack::MiniProfiler.authorize_request
  end

  def message_for(key, options = {})
    t(key, { scope: "sipity/#{controller_name}.action/#{action_name}" }.merge(options))
  end

  def store_previous_path_if_applicable
    raise "This is for Devise" unless defined?(Devise)
    return true unless ["GET", "HEAD"].include?(request.request_method)
    return true unless params.key?('previous_url')
    store_location_for(:user, params['previous_url'])
    true
  end

  # Remove error inserted since we are not showing a page before going to web access,
  # this error message always shows up a page too late. For the moment just remove it always.
  # If we show a transition page in the future we may want to display it then.
  def filter_notify
    return true unless flash[:alert].present?
    flash[:alert] = Array.wrap(flash[:alert]).reject do |alert|
      [
        t('devise.failure.unauthenticated').downcase,
        t('devise.failure.invalid', authentication_keys: Devise.authentication_keys.first).downcase
      ].include?(alert.downcase)
    end
    flash[:alert] = nil unless flash[:alert].present?
    true
  end

  def ssl_configured?
    Figaro.env.protocol == 'https'
  end
end
