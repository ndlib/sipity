Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = true

  # Configure static asset server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.action_mailer.default_url_options = { host: Figaro.env.domain_name }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # If run WITH_I18N_DICTIONARY environment **not** set
  # Finished in 0.09408 seconds (files took 3.07 seconds to load)
  #
  # If run WITH_I18N_DICTIONARY environment set
  # Finished in 0.50963 seconds (files took 2.85 seconds to load)
  unless ENV['WITH_I18N_DICTIONARY']
    config.i18n.enforce_available_locales = false
    I18n.config.enforce_available_locales = false
    I18n.backend = I18n::Backend::KeyValue.new({})
    I18n.backend.store_translations(:en, {})
  end

  # I don't want to be hitting LDAP in all cases; This is the default for test
  # purposes.
  config.default_netid_remote_validator = ->(_a_netid) { true }

  #Use random string for pid rather then using noid service
  config.default_pid_minter = -> { SecureRandom.urlsafe_base64(nil, true) }
  config.active_record.sqlite3.represent_boolean_as_integer = true
end
