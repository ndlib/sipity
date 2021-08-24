require "rails_helper"
require 'sipity/conversions/convert_to_work'

module Sipity
  module Conversions
    describe ConvertToWork do
      include ::Sipity::Conversions::ConvertToWork

      context '.call' do
        it 'will call the underlying conversion method' do
          object = Models::Work.new
          expect(described_class.call(object)).to eq(object)
        end
      end

      context '.convert_to_work' do
        it 'will be private' do
          object = double(to_processing_entity: 1234)
          expect { described_class.convert_to_work(object) }.
            to raise_error(NoMethodError, /private method `convert_to_work'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_work' do
        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_work)
        end

        it 'will return the object if it is a Models::Work' do
          object = Models::Work.new
          expect(convert_to_work(object)).to eq(object)
        end

        it 'will convert a registered action to a Models::Work' do
          work = Models::Work.new
          entity = Models::Processing::Entity.new(proxy_for: work)
          object = Models::Processing::EntityActionRegister.new(entity: entity)
          expect(convert_to_work(object)).to eq(work)
        end

        it 'will attempt to convert the proxied object' do
          work = Models::Work.new
          proxy = double(proxy_for: work)
          expect(convert_to_work(proxy)).to eq(work)
        end

        it 'will return the object there is a #to_work method' do
          work = Models::Work.new
          proxy = double(to_work: work)
          expect(convert_to_work(proxy)).to eq(work)
        end

        it 'will return the object there is a #work method' do
          work = Models::Work.new
          proxy = double(work: work)
          expect(convert_to_work(proxy)).to eq(work)
        end

        it 'will return the object if given an ID of a work' do
          work = Models::Work.create!(id: '123456790')
          expect(convert_to_work(work.id)).to eq(work)
        end

        it 'will raise an error if it cannot convert' do
          object = double
          expect { convert_to_work(object) }.to raise_error(Exceptions::WorkConversionError)
        end
      end
    end
  end
end
