require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter/file_writer'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe FileWriter do
        subject { described_class }
        its(:default_file_utility) { is_expected.to respond_to(:mkdir_p) }
        context '.call' do
          let(:content) { "Some\nText" }
          let(:path) { "/tmp/to/somewhere/great.txt" }
          let(:file_utility) { FileUtils::NoWrite }
          let(:file_handle) { double('FileHandle', puts: true) }
          before do
            allow(File).to receive(:open).with(path, 'w+').and_yield(file_handle)
          end
          it 'will make the containing directory' do
            expect(file_utility).to receive(:mkdir_p).with('/tmp/to/somewhere').and_call_original
            described_class.call(content: content, path: path, file_utility: file_utility)
          end

          it 'will the content to the given path' do
            described_class.call(content: content, path: path, file_utility: file_utility)
            expect(file_handle).to have_received(:puts).with(content)
          end
        end
      end
    end
  end
end
