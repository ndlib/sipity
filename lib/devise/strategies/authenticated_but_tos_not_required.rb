module Devise
  # :nodoc:
  module Strategies
    VALIDATED_RESOURCE_ID_SESSION_KEY = 'warden.user.user.key'.freeze
    TERMS_OF_SERVICE_AGREEMENT_PATH = '/account/'.freeze

    # This strategy enforces that someone is logged in. It is used for the config/routes.rb
    # `devise_for(:user_for_profile_managements)` declaration.
    class AuthenticatedButTosNotRequired < Base
      def valid?
        true
      end

      def authenticate!
        resource = mapping.to.find(resource_id_from_session)
        success!(resource)
      rescue ActiveRecord::RecordNotFound
        fail!(:invalid)
      end

      private

      def resource_id_from_session
        Array.wrap(
          Array.wrap(session["warden.user.user.key"]).first
        ).first
      end
    end
  end
end

Warden::Strategies.add(:authenticated_but_tos_not_required, Devise::Strategies::AuthenticatedButTosNotRequired)
