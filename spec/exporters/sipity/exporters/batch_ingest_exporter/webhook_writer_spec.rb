require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe WebhookWriter do

        let(:exporter) { double('BatchIngestExporter', work_id: 1661, data_directory: '/tmp/sipity-1661', make_data_directory: true) }
        let(:mock_file) { StringIO.new }

        describe '#call' do
          # TODO confirm that Exporter recieves #make_data_directory
          # TODO confirm that write_webook_file is called

          before { allow(described_class).to receive(:output_buffer).and_return(mock_file) }

          it 'bootstraps the data directory' do
            described_class.call(exporter: exporter)
            # expect(exporter).to receive(:make_data_directory)
          end
        end

        describe '#output_buffer' do
          let(:placeholder_file) { File.join(Dir.pwd, 'spec/exporters/sipity/exporters/batch_ingest_exporter/PLACEHOLDER_FILE') }
          subject { described_class.output_buffer(filename: placeholder_file) }
          it { is_expected.to respond_to(:write) }
        end

        describe '#write_contents' do
          let(:example_webhook_url) { 'http://webhook.url.technology' }

          it 'writes the content to the specified file' do
            described_class.write_contents(target: mock_file, content: example_webhook_url)
            mock_file.rewind
            expect(mock_file.read).to eq(example_webhook_url)
          end
        end

        describe '#target_path' do
          subject { described_class.target_path(exporter: exporter) }
          it { is_expected.to eq('/tmp/sipity-1661/WEBHOOK') }
        end

        describe '#callback_url' do
          subject { described_class.callback_url(exporter: exporter) }
          # Figaro.env.protocol! == 'http'
          # Figaro.env.domain_name! == 'localhost:3000'

          it { is_expected.to eq('http://Batch Ingestors:1234@localhost:3000/work_submissions/1661/callback/ingest_completed.json') }

          it 'returns a valid URL' do
            url_pattern = URI::regexp
            expect(subject).to match(url_pattern)
          end
        end

        describe '#authorization_credentials' do
          subject { described_class.authorization_credentials }
          # Figaro.env.sipity_batch_ingester_access_key! == '1234'

          it { is_expected.to eq('Batch Ingestors:1234') }
        end
      end
    end
  end
end
