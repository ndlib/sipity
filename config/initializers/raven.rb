Raven.configure do |config|
  config.dsn = Figaro.env.sentry_dsn
  config.current_environment = Rails.env
  config.release = begin
    identifier = Rails.root.join('VERSION').read.strip
    unless Rails.env.production?
      identifier += " (#{Rails.env})"
    end
    identifier
  rescue Errno::ENOENT
    # irreverent message for cats running this on laptops
    "Moof!"
  end
  config.excluded_exceptions += ['Sipity::Exceptions::AuthorizationFailureError', 'URI::InvalidComponentError']
end
