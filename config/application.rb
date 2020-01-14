require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "active_record/railtie"
# require "active_job/railtie"
require "action_mailer/railtie"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require File.expand_path('../../app/models/sipity', __FILE__)

module Sipity
  class Application < Rails::Application

    config.generators do |g|
      g.assets = false
      g.helper = false

      g.test_framework :rspec,
        fixtures: false,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: false
    end

    config.action_controller.include_all_helpers = false

    [
      'conversions',
      'constraints',
      'data_generators',
      'exporters',
      'forms',
      'jobs',
      'mappers',
      'policies',
      'presenters',
      'processing_hooks',
      'response_handlers',
      'runners',
      'services'
    ].each do |concept|
      config.autoload_paths << Rails.root.join("app/#{concept}")
    end

    config.default_netid_remote_validator = lambda do |a_netid|
      Services::NetidQueryService.valid_netid?(a_netid)
    end

    config.default_pid_minter = lambda do
      Services::NoidMinter.call
    end

    config.default_on_user_create_service = lambda do |a_user|
      Sipity::Services::OnUserCreate.call(a_user)
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.action_dispatch.rescue_responses['Sipity::Exceptions::AuthorizationFailureError'] = :unauthorized
    config.action_dispatch.rescue_responses['Sipity::Exceptions::RequestOutsidePaginationRange'] = :not_found
  end
end
