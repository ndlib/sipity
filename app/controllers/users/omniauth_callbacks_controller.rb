class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
   def oktaoauth
     session[:oktastate] = request.env["omniauth.auth"]  #store all okta data in session
     # get netid
     session[:netid] = request.env["omniauth.auth"]['extra']['raw_info']['netid']
     redirect_to root_path
   end
end
