require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe MetadataWriter do
        let(:metadata) { { hello: 'world' } }
        let(:exporter) { double('BatchIngestExporter', work_id: 1661, data_directory: '/tmp/sipity-1661', make_data_directory: true) }

        context '.call' do
          it "writes the given metadata as an ROF metadata file to the data directory" do
            expect(FileWriter).to receive(:call).with(content: JSON.dump(metadata), path: '/tmp/sipity-1661/metadata-1661.rof')
            described_class.call(metadata: metadata, exporter: exporter)
          end
        end
      end
    end
  end
end
