require 'rails_helper'
# require 'sipity/controllers/authenticated_controller'

module Sipity
  module Controllers
    RSpec.describe AuthenticatedController, type: :controller do
      context '#authenticate_user!' do
        let(:processing_action_name) { 'fun_things' }
        context 'with Basic authentication credentials' do
          it 'will attempt to find authorize_group_from_api_key' do
            user = double('User')
            expect(controller).to(
              receive(:authorize_group_from_api_key).with(group_name: 'User', group_api_key: 'Password').and_return(user)
            )
            request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('User', 'Password')
            controller.authenticate_user!
            expect(controller.instance_variable_get("@current_user")).to eq(user)
          end
        end

        context 'without Basic authentication credentials' do
          it 'will attempt to find authorize_group_from_api_key' do
            expect(controller).to_not receive(:authorize_group_from_api_key)
            expect { controller.authenticate_user! }.to raise_error(StandardError)
            expect(controller.instance_variable_get("@current_user")).to eq(nil)
          end
        end
      end

      context '#current_user' do
        let(:processing_action_name) { 'fun_things' }
        context 'with Basic authentication credentials' do
          it 'will attempt to find authorize_group_from_api_key' do
            user = double('User')
            expect(controller).to(
              receive(:authorize_group_from_api_key).with(group_name: 'User', group_api_key: 'Password').and_return(user)
            )
            request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('User', 'Password')
            controller.current_user
            expect(controller.instance_variable_get("@current_user")).to eq(user)
          end
        end
      end

      context '#authorize_group_from_api_key' do
        let(:valid_name) { Sipity::Models::Group::BATCH_INGESTORS }
        let(:invalid_name) { 'nope' }
        it 'will equal false if its not the ETD Ingester' do
          expect(Sipity::Models::Group).to receive(:find_by).with(name: invalid_name, api_key: 'apassword').and_return(nil)
          expect(
            controller.send(:authorize_group_from_api_key, group_name: invalid_name, group_api_key: 'apassword')
          ).to eq(false)
        end

        it 'will equal false if that password is incorrect' do
          expect(Sipity::Models::Group).to receive(:find_by).with(name: valid_name, api_key: 'nope').and_return(nil)
          expect(controller.send(:authorize_group_from_api_key, group_name: valid_name, group_api_key: 'nope')).to eq(false)
        end

        it 'will be the ETD Ingester group if the name and password match' do
          group = double('Group')
          expect(Sipity::Models::Group).to receive(:find_by).with(name: valid_name, api_key: 'apassword').and_return(group)
          expect(
            controller.send(:authorize_group_from_api_key, group_name: valid_name, group_api_key: 'apassword')
          ).to eq(group)
        end
      end

      context '#enable_profiling' do
        let(:some_user) { double('User',  username: 'someone') }
        
        before do
          allow(controller).to receive(:current_user).and_return(some_user)
          allow(Rails.configuration).to receive(:use_profiler).and_return(true)
        end

        describe 'a valid user' do
          before do
            allow(Rails.configuration).to receive(:profiler_users).and_return([some_user.username])
            allow(Rack::MiniProfiler).to receive(:authorize_request).and_return(true)
          end

          it 'calls authorize_request' do
            expect(controller.send(:enable_profiling)).to eq(true)
          end
        end

        describe 'an invalid user' do
          before do
            allow(Rails.configuration).to receive(:profiler_users).and_return([])
          end

          it 'calls authorize_request' do
            expect(controller.send(:enable_profiling)).to eq(false)
          end
        end
      end
    end
  end
end
