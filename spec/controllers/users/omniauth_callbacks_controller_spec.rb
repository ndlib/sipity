require "rails_helper"
require 'sipity/controllers/visitors_controller'

module Users
  RSpec.describe OmniauthCallbacksController do
    let(:agreed_to_terms_of_service) { false }
    let(:user) { User.new(agreed_to_terms_of_service: agreed_to_terms_of_service) }
    let(:is_persisted) { true }
    let(:omniauth_response) { double("The Auth") }
    describe "#oktaoauth" do
      before do
        request.env['omniauth.auth'] = omniauth_response
        request.env["devise.mapping"] = Devise.mappings[:user]
        allow(User).to receive(:from_omniauth).with(omniauth_response).and_return(user)
        allow(user).to receive(:persisted?).and_return(is_persisted)
      end
      describe 'with successful authentication' do
        describe 'and user agreed to terms of service' do
          let(:agreed_to_terms_of_service) { true }
          it 'will sign them in and redirect them to their previous location' do
            expect(controller).to receive(:sign_in_and_redirect).and_call_original
            get :oktaoauth
            expect(response).to redirect_to(root_path)
          end
        end
        describe 'and user has not agreed to terms of service' do
          let(:agreed_to_terms_of_service) { false }
          it 'will sign them in and redirect them to agree to the terms of service' do
            expect(controller).not_to receive(:sign_in_and_redirect)
            expect(controller).to receive(:sign_in).with(user, event: :authentication).and_call_original
            get :oktaoauth
            expect(response).to redirect_to(account_path)
          end
        end
      end
      describe 'with failed authentication' do
        let(:is_persisted) { false }
        it 'will not sign them in but instead will redirect them to try to sign-in again' do
          expect(controller).not_to receive(:sign_in_and_redirect)
          expect(controller).not_to receive(:sign_in)
          get :oktaoauth
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
