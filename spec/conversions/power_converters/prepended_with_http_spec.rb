require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'prepended_with_http' do
    def self.it_will_convert(value, to:)
      it "converts #{value.inspect} to #{to.inspect}" do
        expect(PowerConverter.convert(value, to: :prepended_with_http)).to eq(to)
      end
    end

    def self.it_will_raise_conversion_error_for(value)
      it "will raise PowerConverter::ConversionError when attempting to convert #{value.inspect}" do
        expect { PowerConverter.convert(value, to: :prepended_with_http) }.to raise_error(PowerConverter::ConversionError)
      end
    end

    it_will_convert('http://google.com', to: 'http://google.com')
    it_will_convert('google.com', to: 'http://google.com')
    it_will_convert('google', to: 'http://google')
    it_will_convert('Punk Rock Theater', to: 'http://Punk Rock Theater')
    it_will_convert('http://Punk Rock Theater', to: 'http://Punk Rock Theater')
    it_will_convert('https://google.com', to: 'https://google.com')
    it_will_convert('ftp://google.com', to: 'ftp://google.com')

    it_will_raise_conversion_error_for(nil)
    it_will_raise_conversion_error_for(:hello)
    it_will_raise_conversion_error_for(Sipity::Models::Work.new)

  end
end
