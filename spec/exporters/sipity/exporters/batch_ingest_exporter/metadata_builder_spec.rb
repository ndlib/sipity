require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe MetadataBuilder do
        it 'exposes .call as a convenience method' do
          expect_any_instance_of(described_class).to receive(:call)
          described_class.call(exporter: exporter)
        end
        let(:work) { double('Work', to_rof_hash: { id: 1 }, attachments: [attachment]) }
        let(:attachment) { double('Attachment', to_rof_hash: { id: 2}) }
        let(:exporter) { double('Exporter', work: work) }
        subject { described_class.new(exporter: exporter) }
        it { is_expected.to delegate_method(:work).to(:exporter) }

        context '#call' do
          it 'will return a hash based on the work and attachment' do
            expect(subject.call).to eq([{ id: 1 }, { id: 2 }])
          end
        end
      end
    end
  end
end
