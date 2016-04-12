require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe WebhookWriter do

        let(:exporter) { double('BatchIngestExporter', work_id: 1661, data_directory: '/tmp/sipity-1661') }

        describe '.call' do
          it "writes the callback url as WEBHOOK in the data directory" do
            expect(FileWriter).to receive(:call).with(content: kind_of(String), path: '/tmp/sipity-1661/WEBHOOK')
            described_class.call(exporter: exporter)
          end
        end
      end
    end
  end
end
