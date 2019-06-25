require "rails_helper"
require 'sipity/conversions/convert_to_permanent_uri'

module Sipity
  module Conversions
    describe ConvertToPermanentUri do
      include ::Sipity::Conversions::ConvertToPermanentUri

      context '.call' do
        it 'will call the underlying conversion method' do
          object = double(work_id: 1234)
          expect(described_class.call(object)).to be_a(String)
        end
      end

      context '.convert_to_permanent_uri' do
        it 'will be private' do
          object = double(work_id: 1234)
          expect { described_class.convert_to_permanent_uri(object) }.
            to raise_error(NoMethodError, /private method `convert_to_permanent_uri'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_permanent_uri' do

        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_permanent_uri)
        end

        it 'converts a decorated work' do
          object = Decorators::WorkDecorator.decorate(Models::Work.new(id: 1234))
          expect(convert_to_permanent_uri(object)).to match(/1234\Z/)
        end

        it 'converts a work' do
          object = Models::Work.new(id: 1234)
          expect(convert_to_permanent_uri(object)).to match(/1234\Z/)
        end

        it 'converts an object related to a work' do
          object = double(work: Models::Work.new(id: 1234))
          expect(convert_to_permanent_uri(object)).to match(/1234\Z/)
        end

        it 'converts an object that has a work_id' do
          object = double(work_id: 1234)
          expect(convert_to_permanent_uri(object)).to match(/1234\Z/)
        end

        it 'will not convert an Integer object (at least until we change that scheme)' do
          object = 1234
          expect { convert_to_permanent_uri(object) }.to raise_error(Exceptions::PermanentUriConversionError)
        end

        it 'will raise an exception if the input is not convertable' do
          object = :hello
          expect { convert_to_permanent_uri(object) }.to raise_error(Exceptions::PermanentUriConversionError)
        end

        it 'will raise an exception if the input is not present' do
          object = ''
          expect { convert_to_permanent_uri(object) }.to raise_error(Exceptions::PermanentUriConversionError)
        end
      end
    end
  end
end
