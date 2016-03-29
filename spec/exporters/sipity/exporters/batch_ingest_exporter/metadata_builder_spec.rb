require 'spec_helper'
require 'sipity/exporters/batch_ingest_exporter'

module Sipity
  module Exporters
    class BatchIngestExporter
      RSpec.describe MetadataBuilder do
        it 'exposes .call as a convenience method' do
          expect_any_instance_of(described_class).to receive(:call)
          described_class.call()
        end
      end
    end
  end
end
