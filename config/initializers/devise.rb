# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
require 'omniauth-oktaoauth'
Devise.setup do |config|
  config.omniauth(
    :oktaoauth,
    Figaro.env.okta_client_id,
    Figaro.env.okta_client_secret,
    scope: 'openid profile email',
    fields: ['profile', 'email'],
    client_options: {
            site: Figaro.env.okta_site,
            authorize_url: Figaro.env.okta_auth_url,
            token_url: Figaro.env.okta_token_url
    },
    redirect_uri: Figaro.env.okta_redirect_uri,
    auth_server_id: Figaro.env.okta_auth_server_id,
    issuer: Figaro.env.okta_site,
    strategy_class: OmniAuth::Strategies::Oktaoauth
  )

  config.case_insensitive_keys = [ :username ]
  config.strip_whitespace_keys = [ :username ]
  config.mailer_sender = 'noreply@nd.edu'
  require 'devise/orm/active_record'
  config.skip_session_storage = [:http_auth]
  config.expire_all_remember_me_on_sign_out = true
  config.sign_out_via = :delete

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  config.warden do |manager|
    manager.default_strategies(scope: :user).unshift(:cas_with_service_agreement)
    manager.default_strategies(scope: :user_for_profile_management).unshift(:authenticated_but_tos_not_required)
  end
end
