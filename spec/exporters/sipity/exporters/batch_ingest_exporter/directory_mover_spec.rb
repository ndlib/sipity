require "rails_helper"
require 'sipity/exporters/batch_ingest_exporter/directory_mover'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe DirectoryMover do

        let(:exporter) do
          double('BatchIngestExporter',
                 file_utility: file_utility,
                 destination_pathname: '/tmp/queue',
                 job_directory: '/tmp/sipity-1492')
        end
        let(:file_utility) { FileUtils::NoWrite }

        describe '.call' do
          it 'prepares the destination path' do
            expect(file_utility).to receive(:mkdir_p).and_call_original
            described_class.call(exporter: exporter, file_utility: file_utility)
          end

          it 'moves the data to the prepared destination path' do
            expect(file_utility).to receive(:mv).and_call_original
            described_class.call(exporter: exporter, file_utility: file_utility)
          end
        end

        it 'uses a file utility to perform its function' do
          expect(exporter.file_utility).to respond_to(:mv)
          expect(exporter.file_utility).to respond_to(:mkdir_p)
        end
      end
    end
  end
end
