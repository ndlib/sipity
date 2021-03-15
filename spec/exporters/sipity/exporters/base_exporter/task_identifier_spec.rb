require "rails_helper"

module Sipity
  module Exporters
    class BaseExporter
      RSpec.describe TaskIdentifier do
        let(:task_function_name) { 'start-doi-minting' }
        let(:content_file) {{ 'Todo' => [task_function_name] }}
        let(:content) { JSON.dump(content_file) }
        let(:work_id) { '1661' }
        let(:data_directory) { '/tmp/sipity-1661' }
        let(:content_path) { '/tmp/sipity-1661/JOB' }

        describe ':files' do
          let(:exporter) do
            double('MintDoiExporter',
                   work_id: work_id,
                   ingest_method: :files,
                   data_directory: data_directory,
                   file_writer: FileWriter,
                   make_data_directory: true)
          end
          context '.call' do
            it "writes the given metadata as json file to the data directory" do
              expect(FileWriter).to receive(:call).with(content: content, path: content_path)
              described_class.call(exporter: exporter, task_function_name: task_function_name)
            end
          end
        end

        describe ':api' do
          let(:exporter) do
            double('MintDoiExporter',
                   work_id: work_id,
                   data_directory: data_directory,
                   ingest_method: :api,
                   file_writer: ApiFileWriter,
                   make_data_directory: true)
          end

          context '.call' do
            it "writes the given metadata as an ROF metadata file to the data directory" do
              expect(ApiFileUtils).to receive(:put_content).with(content_path, content)
              described_class.call(exporter: exporter, task_function_name: task_function_name)
            end
          end
        end
      end
    end
  end
end
