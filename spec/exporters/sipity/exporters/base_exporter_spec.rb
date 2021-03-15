require "rails_helper"

module Sipity
  module Exporters
    RSpec.describe BaseExporter do
      let(:work) { Sipity::Models::Work.new(id: '1234-56') }

      describe 'supported methods' do
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
            expect(subject).to respond_to(:file_writer)
            expect(subject.file_writer).to eq(Sipity::Exporters::BaseExporter::FileWriter)
          end
        end

        context 'when relying on default ingest method' do
          subject { described_class.new(work: work) }

          it 'supports public methods' do
            expect(subject.ingest_method).to eq(:api)
            expect(subject.file_utility).to eq(Sipity::Exporters::BaseExporter::ApiFileUtils)
            expect(subject.work_id).to eq(work.to_param)
            expect(subject).to respond_to(:job_directory)
            expect(subject).to respond_to(:data_directory)
            expect(subject).to respond_to(:destination_pathname)
            expect(subject.job_directory).to match(%r{/sipity-#{work.to_param}})
            expect(subject.data_directory).to eq(subject.job_directory + '/files')
            expect(subject.data_directory_basename).to match(/^sipity-#{work.to_param}$/)
            expect(subject.destination_pathname).to eq(subject.job_directory + '/queue')
            expect(subject).to respond_to(:file_writer)
            expect(subject.file_writer).to eq(Sipity::Exporters::BaseExporter::ApiFileWriter)
          end

          context 'when default_ingest_method is :files' do
            let(:subject) { described_class.new(work: work, ingest_method: :files) }

            before do
              expect(subject).to receive(:default_ingest_method).and_return(:files)
            end

            it 'finds default_file_utility' do
              expect(subject.send(:default_file_utility)).to eq(FileUtils)
            end
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
end
