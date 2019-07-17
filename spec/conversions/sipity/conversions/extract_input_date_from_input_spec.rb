require "rails_helper"
require 'sipity/conversions/extract_input_date_from_input'

module Sipity
  module Conversions
    RSpec.describe ExtractInputDateFromInput do
      include ExtractInputDateFromInput

      it 'will extract based on direct input' do
        attributes = { 'defense_date' => 'Hello World' }
        expect(extract_input_date_from_input(:defense_date, attributes)).to eq('Hello World')
      end

      it 'will extract based on Rails convention' do
        attributes = ActionController::Parameters.new('defense_date(1i)' => '2014', 'defense_date(2i)' => '11', 'defense_date(3i)' => '28')
        expect(extract_input_date_from_input(:defense_date, attributes)).to eq('2014-11-28')
      end

      it 'will yield if neither is met' do
        attributes = {}
        expect(extract_input_date_from_input(:defense_date, attributes) { 'yielded' }).to eq('yielded')
      end
    end
  end
end
