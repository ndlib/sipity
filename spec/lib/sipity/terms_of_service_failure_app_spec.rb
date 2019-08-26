require 'rails_helper'
require 'sipity/terms_of_service_failure_app'

module Sipity
  RSpec.describe TermsOfServiceFailureApp do
    let(:env) do
      {
        'REQUEST_URI' => 'http://test.host/',
        'HTTP_HOST' => 'test.host',
        'REQUEST_METHOD' => 'GET',
        'warden.options' => { scope: :user },
        'rack.input' => "",
        'warden' => warden
      }
    end
    let(:warden) { double("Warden", message: warden_message) }
    describe '#respond' do
      describe 'when warden_message is :unsigned_tos' do
        let(:warden_message) { :unsigned_tos }
        it 'stores the location and redirects to accounts' do
          http_code, headers, _env = described_class.call(env)
          expect(http_code).to eq(302)
          expect(headers.fetch("Location")).to eq(File.join(env["REQUEST_URI"], "/account/"))
        end
      end
      describe 'when warden_message is NOT :unsigned_tos' do
        let(:warden_message) { :NOT_unsigned_tos }
        it 'redirects to sign in' do
          http_code, headers, _env = described_class.call(env)
          expect(http_code).to eq(302)
          expect(headers.fetch("Location")).to eq(File.join(env["REQUEST_URI"], "/sign_in"))
        end
      end
    end
  end
end
