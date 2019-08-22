module Devise
  # :nodoc:
  module Strategies
    VALIDATED_RESOURCE_ID_SESSION_KEY = 'validated_resource_id'.freeze
    TERMS_OF_SERVICE_AGREEMENT_PATH = '/account'.freeze
    # Authenticate a user but handle the case in which the user has not yet
    # agreed to terms of service.
    #
    # @see Devise::Strategies::ValidatedButTermsOfServiceAgreementNotRequired
    # @see Devise::Strategies::CasAuthenticatable
    class CasAuthenticationWithServiceAgreement < Base
      # @todo I believe this is not working at present. However, I want this
      # in place to make sure we have a TOS agreement.
      def authenticate!
        if session[VALIDATED_RESOURCE_ID_SESSION_KEY]
          begin
            resource = mapping.to.find(resource_id_from_session)
            success!(resource)
          rescue ActiveRecord::RecordNotFound
            fail!(:invalid)
          end
        else
          fail!(:invalid)
        end
      end

      # I need to alter the success criteria for CasAuthenticatable; Because
      # we are enforcing that users must agree to terms of service.
      def success!(resource)
        session[VALIDATED_RESOURCE_ID_SESSION_KEY] = resource.id
        if resource.agreed_to_terms_of_service?
          super(resource)
        else
          uri = URI.parse(request.url)
          uri.query = nil
          uri.path = TERMS_OF_SERVICE_AGREEMENT_PATH
          redirect!(uri.to_s)
        end
      end

      private

      def resource_id_from_session
        session[VALIDATED_RESOURCE_ID_SESSION_KEY]
      end
    end

    # Authenticate a user that was validated by another strategy, but for some
    # reason did not pass.
    #
    # @example
    #   I go to a page that requires user authentication and agreement to ToS,
    #   Devise authenticates the user but discovers that they have not agreed to
    #   the ToS; So it redirects to the ToS agreement page.
    #
    # @example
    #   If I go directly to the ToS agreement page, I don't want to try this
    #   strategy. Instead fall back to another one (i.e. the original
    #   Devise::Strategies::CasAuthenticatable).
    #
    # @see Devise::Strategies::CasAuthenticationWithServiceAgreement
    # @see Devise::Strategies::CasAuthenticatable
    class ValidatedButTermsOfServiceAgreementNotRequired < Base
      def valid?
        resource_id_from_session
      end

      def authenticate!
        resource = mapping.to.find(resource_id_from_session)
        success!(resource)
      rescue ActiveRecord::RecordNotFound
        fail!(:invalid)
      end

      private

      def resource_id_from_session
        session[VALIDATED_RESOURCE_ID_SESSION_KEY]
      end
    end
  end
end

Warden::Strategies.add(:cas_with_service_agreement, Devise::Strategies::CasAuthenticationWithServiceAgreement)
Warden::Strategies.add(:authenticated_but_tos_not_required, Devise::Strategies::ValidatedButTermsOfServiceAgreementNotRequired)
