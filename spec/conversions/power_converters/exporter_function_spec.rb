require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'exporter_function' do
    it "will successfully coerce a lambda" do
      input = ->(_) {}
      expect(PowerConverter.convert(input, to: :exporter_function)).to eq(input)
    end

    it "will coerce a well formed string" do
      input = 'etd'
      expect(PowerConverter.convert(input, to: :exporter_function)).to eq(Sipity::Exporters::EtdExporter)
    end

    ['::Sipity::Models::Work', 'Sipity::Exporters::EtdExporter', 'Spam', 'etd_exporter', 'etds', 'exporters/etd'].each do |given|
      it "will not convert #{given.inspect}" do
        expect { PowerConverter.convert(given, to: :exporter_function) }.to raise_error(PowerConverter::ConversionError)
      end
    end
  end
end
