require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe AttachmentWriter do
        let(:work) { Models::Work.new(id: '123') }
        let(:exporter) { double('exporter', with_path_to_data_directory: true) }
        let(:work_to_attachments_converter) { double('work_to_attachments_converter', call: [attachment]) }
        let(:attachment) { Models::Attachment.new(pid: 'abc:123', file: __FILE__) }
        it 'exposes .call as a convenience method' do
          expect_any_instance_of(described_class).to receive(:call)
          described_class.call(work: work, exporter: exporter)
        end
        subject { described_class.new(work: work, exporter: exporter, work_to_attachments_converter: work_to_attachments_converter) }

        its(:default_work_to_attachments_converter) { is_expected.to respond_to(:call) }
        let(:temporary_directory) { '/tmp/hello/world' }

        context '#call' do
          before do
            allow(exporter).to receive(:with_path_to_data_directory).and_yield(temporary_directory)
          end
          it "copies each of the attachments to the exporter's provided data directory" do
            subject.call
            attachment_pathname = Pathname.new(File.join(temporary_directory, "#{attachment.pid}-#{attachment.file_name}"))
            expect(attachment_pathname.exist?).to eq(true)
          end
        end
      end
    end
  end
end
