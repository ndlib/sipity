require "rails_helper"
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe MetadataWriter do
        describe ':files' do
          let(:metadata) { { hello: 'world' } }
          let(:exporter) do
            double('BatchIngestExporter',
                   work_id: 1661,
                   ingest_method: :files,
                   data_directory: '/tmp/sipity-1661',
                   make_data_directory: true)
          end
          context '.call' do
            it "writes the given metadata as an ROF metadata file to the data directory" do
              expect(FileWriter).to receive(:call).with(content: JSON.dump(metadata), path: '/tmp/sipity-1661/metadata-1661.rof')
              described_class.call(metadata: metadata, exporter: exporter)
            end
          end
        end

        describe ':api' do
          let(:path) { '/tmp/sipity-1661/files/metadata-1661.rof' }
          let(:metadata) { { hello: 'world' } }
          let(:content) { JSON.dump(metadata) }
          let(:exporter) do
            double('BatchIngestExporter',
                   work_id: 1661,
                   ingest_method: :api,
                   data_directory: '/tmp/sipity-1661/files')
          end

          context '.call' do
            it "writes the given metadata as an ROF metadata file to the data directory" do
              expect(ApiFileUtils).to receive(:put_content).with(path, content)
              described_class.call(metadata: metadata, exporter: exporter)
            end
          end
        end
      end
    end
  end
end
