require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    RSpec.describe BatchIngestExporter do
      let(:work) { Sipity::Models::Work.new(id: '1234-56') }

      xit 'exposes .call as a convenience method' do
        expect_any_instance_of(described_class).to receive(:call)
        described_class.call(work: work)
      end
    end
  end
end
