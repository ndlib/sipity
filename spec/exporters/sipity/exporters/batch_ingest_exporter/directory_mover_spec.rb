require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe DirectoryMover do

        let(:exporter) { double('BatchIngestExporter', data_directory: '/tmp/sipity-1492') }
        let(:source) { exporter.data_directory }
        let(:destination) { 'tmp/queue' }

        FileUtils = FileUtils::NoWrite

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
          subject { described_class.prepare_destination(path: destination) }
          # FileUtils.mkdir_p returns an array of the directories that were created
          it { is_expected.to eq(Array.wrap(destination)) }
        end

        describe '#move_files' do
          # FileUtils::NoWrite.mv always returns nil; it is difficult to verify correctness
          it 'calls the .mv method' do
            expect(FileUtils).to receive(:mv)
            described_class.move_files(source: source, destination: destination)
          end
        end
      end
    end
  end
end
