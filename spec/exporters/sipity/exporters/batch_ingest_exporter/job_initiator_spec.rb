require "rails_helper"
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe JobInitiator do
        describe ':files' do
          let(:file_utility) { FileUtils::NoWrite }
          let(:exporter) do
            double('BatchIngestExporter',
                   file_utility: file_utility,
                   job_directory: path,
                   ingest_method: :files)
          end
          let(:path) { '/tmp/sipity-1492' }

          context '.call' do
            it 'uses a file utility to perform its function' do
              expect(exporter.file_utility).to respond_to(:mkdir_p)
            end

            it 'will make the directory' do
              expect(file_utility).to receive(:mkdir_p).with(path).and_call_original
              described_class.call(exporter: exporter)
            end
          end
        end

        describe ':api' do
          let(:file_utility) { double('ApiFileUtils') }
          let(:response) { [] }
          let(:exporter) do
            double('BatchIngestExporter',
                   file_utility: file_utility,
                   job_directory: path,
                   ingest_method: :api)
          end
          let(:path) { '/tmp/sipity-1492' }

          it 'will make the directory via api' do
            expect(file_utility).to receive(:put_content).with(path).and_return(response)
            described_class.call(exporter: exporter)
          end
        end
      end
    end
  end
end
