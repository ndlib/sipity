module Sipity
  # Responsible for handling an authenticated user that
  # has not signed a terms of service.
  class TermsOfServiceFailureApp < Devise::FailureApp
    def respond
      if warden_message == :unsigned_tos
        redirect_for_unsigned_tos
      else
        super
      end
    end

    def redirect_for_unsigned_tos
      store_location!
      redirect_to "/account/"
    end
  end
end
