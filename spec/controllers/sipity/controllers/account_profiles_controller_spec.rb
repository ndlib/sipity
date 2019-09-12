require "rails_helper"
require 'sipity/controllers/account_profiles_controller'
require 'hesburgh/lib/mock_runner'

module Sipity
  module Controllers
    RSpec.describe AccountProfilesController, type: :controller do

      context '#current_user' do
        let(:user) { double }
        it 'will use the #current_user_for_profile_management if there is no current user' do
          expect(controller).to receive(:current_user_for_profile_management).and_return(user)
          expect(controller.current_user).to eq(user)
        end
      end

      let(:user) { double('User') }
      context 'GET #edit' do
        before { controller.runner = runner }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: { attributes: attributes }, context: controller
          )
        end
        let(:attributes) { { "preferred_name" => 'bogus' } }
        let(:yields) { user }
        let(:callback_name) { :success }
        it 'will render the edit page' do
          get 'edit', params: { account: attributes }
          expect(assigns(:model)).to_not be_nil
          expect(response).to render_template('edit')
        end
      end

      context 'POST #update' do
        let(:callback_name) { :success }
        let(:runner) do
          Hesburgh::Lib::MockRunner.new(
            yields: yields, callback_name: callback_name, run_with: { attributes: attributes }, context: controller
          )
        end
        let(:attributes) { { 'preferred_name' => 'bogus' } }
        before { controller.runner = runner }
        context 'on success' do
          let(:callback_name) { :success }
          let(:yields) { user }
          it 'will redirect to the dashboard' do
            post 'update', params: { account: attributes }
            expect(flash[:notice]).to_not be_empty
            expect(assigns(:model)).to be_nil
            expect(response).to redirect_to(dashboard_path)
          end
          it 'will redirect to the specified user_return_to if given' do
            controller.session['user_return_to'] = '/hello/world'
            post 'update', params: { account: attributes }
            expect(response).to redirect_to('/hello/world')
          end
        end
        context 'on failure' do
          let(:form) { double('Form') }
          let(:callback_name) { :failure }
          let(:yields) { form }
          it 'will render the work again' do
            post 'update', params: { account: attributes }
            expect(assigns(:model)).to be_present
            expect(response).to render_template('edit')
          end
        end
      end
    end
  end
end
