require "rails_helper"
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    RSpec.describe BatchIngestExporter do
      let(:work) { Sipity::Models::Work.new(id: '1234-56') }

      it 'exposes .call as a convenience method' do
        expect_any_instance_of(described_class).to receive(:call)
        described_class.call(work: work)
      end

      context 'when specifying :files ingest method' do
        subject { described_class.new(work: work, file_utility: FileUtils, ingest_method: :files) }

        it 'supports public methods' do
          expect(subject).to respond_to(:file_utility)
          expect(subject).to respond_to(:ingest_method)
          expect(subject.work_id).to eq(work.to_param)
          expect(subject).to respond_to(:job_directory)
          expect(subject).to respond_to(:data_directory)
          expect(subject).to respond_to(:destination_pathname)
          expect(subject.job_directory).to match(%r{/sipity-#{work.to_param}})
          expect(subject.data_directory).to eq(subject.job_directory)
          expect(subject.data_directory_basename).to match(/^sipity-#{work.to_param}$/)
          expect(subject.destination_pathname).to eq('tmp/queue')
        end
      end

      context 'when relying on default ingest method' do
        subject { described_class.new(work: work) }

        it 'supports public methods' do
          expect(subject).to respond_to(:file_utility)
          expect(subject).to respond_to(:ingest_method)
          expect(subject.ingest_method).to eq(:api)
          expect(subject.file_utility).to eq(Sipity::Exporters::BatchIngestExporter::ApiFileUtils)
          expect(subject.work_id).to eq(work.to_param)
          expect(subject).to respond_to(:job_directory)
          expect(subject).to respond_to(:data_directory)
          expect(subject).to respond_to(:destination_pathname)
          expect(subject.job_directory).to match(%r{/sipity-#{work.to_param}})
          expect(subject.data_directory).to eq(subject.job_directory + '/files')
          expect(subject.data_directory_basename).to match(/^sipity-#{work.to_param}$/)
          expect(subject.destination_pathname).to eq(subject.job_directory + '/queue')
        end
      end

      context '#call' do
        subject { described_class.new(work: work, file_utility: FileUtils, ingest_method: :files) }

        it 'writes attachments, builds metadata, writes the metadata file, writes the webhook, then moves the directory' do
          expect(described_class::JobInitiator).to receive(:call)
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
