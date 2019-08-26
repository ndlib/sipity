require "rails_helper"
require 'devise/strategies/authenticated_but_tos_not_required'

module Devise
  module Strategies
    RSpec.describe AuthenticatedButTosNotRequired do
      context 'with a validated session resource id' do
        let!(:resource) { User.create!(username: 'hello', agreed_to_terms_of_service: true) }
        let(:env) { { 'rack.session' => { Devise::Strategies::VALIDATED_RESOURCE_ID_SESSION_KEY => resource.id } } }
        subject { described_class.new(env) }

        before do
          allow(subject).to receive(:mapping).and_return(Devise.mappings.fetch(:user))
        end

        it 'will be valid if the session has been set' do
          expect(subject).to be_valid
        end

        it 'will be successful if the resource is found' do
          expect(subject).to receive(:success!).with(resource)
          subject.authenticate!
        end

        context 'with user id that is missing' do
          let(:env) { { 'rack.session' => { Devise::Strategies::VALIDATED_RESOURCE_ID_SESSION_KEY => '-1' } } }
          it 'will raise if the resource is not found' do
            expect(subject).to receive(:fail!).with(:invalid)
            subject.authenticate!
          end
        end
      end

      context 'without a validated session resource id' do
        let(:env) { { 'rack.session' => {} } }
        subject { described_class.new(env) }

        it 'will be valid' do
          expect(subject).to be_valid
        end
      end
    end
  end
end
