require "rails_helper"

module Sipity
  module Exporters
    class BaseExporter
      RSpec.describe MetadataBuilder do
        let(:work) { double('Work') }
        let(:exporter) { double('Exporter', work: work) }
        context '.call' do
          it 'should delegate to Sipity::Conversions::ToRof::WorkConverter' do
            expect(Sipity::Conversions::ToRof::WorkConverter).to receive(:call).with(work: work)
            subject.call(exporter: exporter)
          end
        end
      end
    end
  end
end
