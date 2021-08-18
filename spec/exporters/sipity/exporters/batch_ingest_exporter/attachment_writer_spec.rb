require "rails_helper"

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe AttachmentWriter do
        let(:subject) do
          described_class.new(
            work: work,
            exporter: exporter,
            work_to_attachments_converter: work_to_attachments_converter
          )
        end
        let(:exporter) do
          double('exporter',
                  work: work,
                  work_id: work.id,
                  data_directory: data_directory,
                  ingest_method: ingest_method,
                  file_utility: file_utility,
                  file_writer: file_writer
                )
        end
        let(:work) { Models::Work.new(id: '123') }
        let(:attachments) { [attachment1, attachment2] }
        let(:attachment1) { Models::Attachment.new(
                  work_id: work.id, 
                  pid: 'abcabc', 
                  predicate_name: 'attachment',
                  file_uid: "2021/08/17/5t2fiqw7ej_file_abc.jpg",
                  file_name: "file_abc.jpg")
         }
         let(:attachment2) { Models::Attachment.new(
                  work_id: work.id, 
                  pid: 'abcdef', 
                  predicate_name: 'attachment',
                  file_uid: "2021/08/17/5t2fiqw7ej_file_def.jpg",
                  file_name: "file_def.jpg")
         }
        let(:work_to_attachments_converter) { 
          double('work_to_attachments_converter', call: attachments) 
        }
        let(:filename) { 
          File.join(data_directory, "attachments-#{exporter.work_id}.json") 
        }
        let(:content) { attachments.to_json }

        describe':files' do
          let(:ingest_method) { :files }
          let(:file_utility) { FileUtils }
          let(:file_writer) { FileWriter }
          let (:data_directory) { '/tmp/sipity-1661' }

          it 'exposes .call as a convenience method' do
            expect_any_instance_of(described_class).to receive(:call)
            subject.call
          end

          its(:default_work_to_attachments_converter) { is_expected.to respond_to(:call) }

          context '#call' do
            it "writes a json file with attachment data" do
              expect(FileWriter).to receive(:call).with(content: content, path: filename)
              subject.call
            end
          end
        end

        describe ':api' do
          let(:ingest_method) { :api }
          let(:file_utility) { Sipity::Exporters::BaseExporter::ApiFileUtils}
          let(:file_writer) { ApiFileWriter }
          let (:data_directory) { '/tmp/sipity-1661/files' }

          it "calls writes attachments as a json file" do
            expect(ApiFileWriter).to receive(:call).with(content: content, path: filename)
            subject.call
          end
        end
      end
    end
  end
end
