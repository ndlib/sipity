require 'spec_helper'

module Sipity
  module Conversions
    describe ConvertToDate do
      include ::Sipity::Conversions::ConvertToDate

      context '.call' do
        it 'will call the underlying conversion method' do
          expect(described_class.call(Date.new(2014, 12, 1))).to eq(Date.new(2014, 12, 1))
        end
      end

      context '.convert_to_date' do
        it 'will be private' do
          expect { described_class.convert_to_date(Date.new(2014, 12, 1)) }.
            to raise_error(NoMethodError, /private method `convert_to_date'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_date' do

        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_date)
        end

        [
          ['2014-12-01', Date.new(2014, 12, 1)],
          ['12/10/2013', Date.new(2013, 10, 12)],
          [Date.new(2014, 12, 1), Date.new(2014, 12, 1)]
        ].each_with_index do |(to_convert, expected), index|
          it "will convert #{to_convert.inspect} to #{expected} (Scenario ##{index}" do
            expect(convert_to_date(to_convert)).to eq(expected)
          end
        end

        it 'will raise an exception if unparsable' do
          expect { convert_to_date(1) }.to raise_error(Exceptions::DateConversionError)
        end

        it 'will yield and not raise if unparsable but block is given' do
          today = Date.today
          expect(convert_to_date(1) { today }).to eq(today)
        end
      end
    end
  end
end
