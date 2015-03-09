require 'hesburgh/lib/controller_with_runner'

# The foundational controller for this application
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Hesburgh::Lib::ControllerWithRunner
  before_action :filter_notify

  # So you can easily invoke the public repository of Sipity.
  # It is the repository that indicates what the application can and is doing.
  def repository
    if request.get?
      Sipity::QueryRepository.new
    else
      Sipity::CommandRepository.new
    end
  end
  helper_method :repository

  private

  def message_for(key, options = {})
    t(key, { scope: "sipity/#{controller_name}.action/#{action_name}" }.merge(options))
  end

  # Remove error inserted since we are not showing a page before going to web access, this error message always shows up a page too late.
  # for the moment just remove it always.  If we show a transition page in the future we may want to  display it then.
  def filter_notify
    return unless flash[:alert].present?
    flash[:alert] = [flash[:alert]].flatten.reject do |item|
      item == "You need to sign in or sign up before continuing."
    end
    flash[:alert] = nil if flash[:alert].blank?
  end
end
