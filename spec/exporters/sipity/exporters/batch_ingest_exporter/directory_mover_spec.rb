require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter/directory_mover'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe DirectoryMover do

        let(:exporter) { double('BatchIngestExporter', data_directory: '/tmp/sipity-1492') }
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

        subject { described_class }
        its(:default_file_utility) { is_expected.to respond_to(:mv) }
        its(:default_file_utility) { is_expected.to respond_to(:mkdir_p) }
      end
    end
  end
end
