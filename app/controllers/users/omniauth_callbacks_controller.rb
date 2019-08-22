# A devise recommneded namespace for authentication related antics
module Users
  # Responsible for exposing Okta authentication behavior
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def oktaoauth
      @user = User.from_omniauth(request.env["omniauth.auth"])
      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: "Okta") if is_navigational_format?
      else
        redirect_to new_user_session_path
      end
    end

    def failure
      redirect_to root_path
    end
  end
end
