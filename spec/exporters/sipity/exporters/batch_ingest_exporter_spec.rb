require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    RSpec.describe BatchIngestExporter do
      let(:work) { Sipity::Models::Work.new(id: '1234-56') }

      it 'exposes .call as a convenience method' do
        expect_any_instance_of(described_class).to receive(:call)
        described_class.call(work: work)
      end

      subject { described_class.new(work: work) }
      its(:work_id) { is_expected.to eq(work.to_param) }
      its(:data_directory) { is_expected.to match(%r{/sipity-#{work.to_param}}) }
      its(:default_file_utility) { is_expected.to respond_to(:mkdir_p) }
      its(:data_directory_basename) { is_expected.to match(/^sipity-#{work.to_param}$/) }

      context '#queue_pathname' do
        subject { described_class.new(work: work).queue_pathname }
        its(:to_s) { is_expected.to match(%r{/sipity-#{work.to_param}}) }
        it { is_expected.to be_a(Pathname) }
      end

      context '#call' do
        it 'writes attachments, builds metadata, writes the metadata file, writes the webhook, then moves the directory' do
          expect(described_class::AttachmentWriter).to receive(:call)
          expect(described_class::MetadataBuilder).to receive(:call)
          expect(described_class::MetadataWriter).to receive(:call)
          expect(described_class::WebhookWriter).to receive(:call)
          expect(described_class::DirectoryMover).to receive(:call)
          subject.call
        end
      end

      context '#with_path_to_data_directory' do
        let(:file_utility) { double('File Utility', mkdir_p: true) }
        subject { described_class.new(work: work, file_utility: file_utility) }
        it 'will yield the #data_directory' do
          expect { |b| subject.with_path_to_data_directory(&b) }.to yield_with_args(subject.data_directory)
        end

        it 'will conditionally create the given #data_directory' do
          subject.with_path_to_data_directory
          expect(file_utility).to have_received(:mkdir_p).with(subject.data_directory)
        end
      end
    end
  end
end
