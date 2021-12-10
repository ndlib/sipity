require "rails_helper"

module Sipity
  module Exporters
    RSpec.describe FileReplacementExporter do
      let(:work) { Sipity::Models::Work.new(id: '1234-56') }

      it 'exposes .call as a convenience method' do
        expect_any_instance_of(described_class).to receive(:call)
        described_class.call(work: work)
      end

      context '#call' do
        subject { described_class.new(work: work, file_utility: FileUtils, ingest_method: :files) }

        it 'performs all necessary tasks' do
          expect(Sipity::Exporters::BaseExporter::JobInitiator).to receive(:call)
          expect(Sipity::Exporters::BaseExporter::TaskIdentifier).to receive(:call)
          expect(Sipity::Exporters::FileReplacementExporter::AttachmentWriter).to receive(:call)
          expect(Sipity::Exporters::BaseExporter::WebhookWriter).to receive(:call)
          expect(Sipity::Exporters::BaseExporter::DirectoryMover).to receive(:call)
          subject.call
        end
      end
    end
  end
end
