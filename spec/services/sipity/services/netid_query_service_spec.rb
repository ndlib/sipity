require 'rails_helper'
require 'sipity/services/netid_query_service'

module Sipity
  module Services
    RSpec.describe NetidQueryService do
      # Rubocop doesn't like this, but I want the injected URL reader
      # to have the same method signature

      # rubocop:disable Lint/UnusedBlockArgument
      let(:url_reader) { ->(url:) { response } }
      # rubocop:enable Lint/UnusedBlockArgument
      let(:response) { nil }
      let(:netid) { 'somenetid' }
      let(:full_name) { 'Full Name' }
      let(:url) { double }

      let(:service) { described_class.new(netid, url_reader: url_reader) }

      context '.read' do
        let(:url) { double }
        let(:response) { StringIO.new(body) }
        let(:body) { 'hello' }
        it 'opens the URL and reads the content' do
          expect(described_class).to receive(:open).with(url).and_return(response)
          expect(described_class.read(url: url)).to eq(body)
        end
      end
      context '.read_without_ssl_verification' do
        let(:url) { double }
        let(:response) { StringIO.new(body) }
        let(:body) { 'hello' }
        it 'opens the URL and reads the content' do
          expect(described_class).to receive(:open).with(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).and_return(response)
          expect(described_class.read_without_ssl_verification(url: url)).to eq(body)
        end
      end

      context 'default reader' do
        it 'reads via OpenSSL' do
          expect(described_class.new(netid).url_reader).to eq(described_class.method(:read))
        end
        it 'has the same method signature as the injected url_reader' do
          expect(described_class.new(netid).url_reader.parameters).to eq(url_reader.parameters)
        end
      end

      context '.preferred_name' do
        it 'will get preferred_name for the given netid' do
          expect(described_class).to receive_message_chain(:new, :preferred_name).
            and_return(full_name)
          expect(described_class.preferred_name(netid)).to eq(full_name)
        end
      end

      context '.valid_netid?' do
        context 'with valid netid' do
          subject { described_class.valid_netid?(netid) }
          before { expect(described_class).to receive_message_chain(:new, :valid_netid?).and_return(true) }
          it { is_expected.to be_truthy }
        end
      end

      context 'with an empty netid' do
        let(:netid) { " " }
        it 'will assume that is invalid and not call the remote service' do
          expect(url_reader).to_not receive(:call)
          expect(service.valid_netid?).to eq(false)
        end
      end

      context 'with netid that has a space' do
        let(:response) { valid_response_with_netid }
        let(:netid) { " somenetid" }
        it 'gracefully handles a netid with a space in it' do
          # https://errbit.library.nd.edu/apps/55280e706a6f68a6d2090000/problems/5571ba3b6a6f685aa1141200
          expect(service.valid_netid?).to eq('a_netid')
        end
      end

      context '#preferred_name' do
        subject { service.preferred_name }
        context 'when the url_reader raises an HTTPError' do
          it 'will use the netid for the preferred name' do
            expect(url_reader).to receive(:call).and_raise(OpenURI::HTTPError.new('', ''))
            expect(subject).to eq(netid)
          end
        end

        context 'when the requested NetID is not found for a person' do
          let(:response) { valid_response_but_not_for_a_user }
          it 'will use the netid for the preferred name' do
            expect(subject).to eq(netid)
          end
        end

        context 'when the NetID is found in the remote service' do
          let(:response) { valid_response_with_netid }
          it 'will use the preferred name' do
            expect(subject).to eq('Bob the Builder')
          end
        end

        context 'when the document is malformed' do
          let(:response) { invalid_document }
          it 'will raise an exception if the returned document is malformed' do
            expect { subject }.to raise_error(NoMethodError)
          end
        end
      end

      context '#valid_netid?' do
        subject { service.valid_netid? }
        context 'when the url_reader raises an HTTPError' do
          before { expect(url_reader).to receive(:call).and_raise(OpenURI::HTTPError.new('', '')) }
          it { is_expected.to be_falsey }
        end

        context 'when the requested NetID is not found for a person' do
          let(:response) { valid_response_but_not_for_a_user }
          it { is_expected.to be_falsey }
        end

        context 'when the NetID is found in the remote service' do
          let(:response) { valid_response_with_netid }
          it { is_expected.to be_truthy }
        end

        context 'when the document is malformed' do
          let(:response) { invalid_document }
          it 'will raise an exception if the returned document is malformed' do
            expect { subject.valid_netid? }.to raise_error(NoMethodError)
          end
        end
      end

      let(:valid_response_with_netid) do
        <<-DOCUMENT
        {
          "people":[
            {
              "id":"a_netid","identifier_contexts":{
                "ldap":"uid","staff_directory":"email"
              },"identifier":"by_netid","netid":"a_netid","first_name":"Bob","last_name":"the Builder", "full_name":"Bob the Builder"
            }
          ]
        }
        DOCUMENT
      end
      let(:valid_response_but_not_for_a_user) do
        <<-DOCUMENT
        {
          "people":[
            {
              "id":"a_netid","identifier_contexts":{
                "ldap":"uid","staff_directory":"email"
              },"identifier":"by_netid","contact_information":{}
            }
          ]
        }
        DOCUMENT
      end

      let(:invalid_document) do
        <<-DOCUMENT
        {
          "people": null
        }
        DOCUMENT
      end

    end
  end
end
