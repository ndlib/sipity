# A devise recommneded namespace for authentication related antics
module Users
  # Responsible for exposing Okta authentication behavior
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def oktaoauth
      @user = User.from_omniauth(request.env["omniauth.auth"])
      if @user.persisted?
        sign_in_and_handle_tos(kind: "Okta")
      else
        redirect_to new_user_session_path
      end
    end

    private

    def sign_in_and_handle_tos(kind:)
      if @user.agreed_to_terms_of_service?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
      else
        sign_in(@user, event: :authentication)
        set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
        set_flash_message(:notice, :prompt_agreement_for_tos) if is_navigational_format?
        redirect_to account_path
      end
    end
  end
end
