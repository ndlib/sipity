require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe DirectoryMover do

        let(:exporter) { double('BatchIngestExporter', data_directory: '/tmp/sipity-1492') }
        FileUtils = FileUtils::DryRun

        describe '#call' do
          it 'prepares the destination path' do
            expect(described_class).to receive(:prepare_destination)
            described_class.call(exporter: exporter)
          end

          it 'moves the data to the destination path' do
            expect(described_class).to receive(:move_files)
            described_class.call(exporter: exporter)
          end
        end

        describe '#prepare_destination' do
        end

        describe '#move_files' do
        end
      end
    end
  end
end
