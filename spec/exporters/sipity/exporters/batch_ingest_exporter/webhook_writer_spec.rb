require "rails_helper"
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe WebhookWriter do
        let(:authorization_credentials) { 'group with space:password' }
        describe ':files' do
          let(:exporter) { double('BatchIngestExporter', work_id: 1661, ingest_method: :files, data_directory: '/tmp/sipity-1661') }
          before do
            allow(Models::Group).to receive(:basic_authorization_string_for!).and_return(authorization_credentials)
          end
          describe '.call' do
            it "writes the callback url as WEBHOOK in the data directory" do
              expect(FileWriter).to receive(:call).with(content: kind_of(String), path: '/tmp/sipity-1661/WEBHOOK')
              described_class.call(exporter: exporter)
            end
          end
          describe '.callback_url' do
            it "generates a callback URL" do
              expect(
                described_class.callback_url(work_id: '1234', authorization_credentials: authorization_credentials)
              ).to(
                eq(
                  URI.encode("http://#{authorization_credentials}@localhost:3000/work_submissions/1234/callback/ingest_completed.json")
                )
              )
            end
          end
        end

        describe ':api' do
          let(:path) { '/tmp/sipity-1661/files/WEBHOOK' }
          let(:content) do
            URI.encode("http://#{authorization_credentials}@localhost:3000/work_submissions/1661/callback/ingest_completed.json")
          end
          let(:exporter) { double('BatchIngestExporter', work_id: 1661, ingest_method: :api, data_directory: '/tmp/sipity-1661/files') }
          before do
            allow(Models::Group).to receive(:basic_authorization_string_for!).and_return(authorization_credentials)
          end

          describe '.call' do
            it "writes the callback url as WEBHOOK in the data directory" do
              expect(ApiFileUtils).to receive(:put_content).with(path, content)
              described_class.call(exporter: exporter)
            end
          end
        end
      end
    end
  end
end
