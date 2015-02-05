require 'spec_helper'

module Sipity
  module Conversions
    describe ConvertToProcessingEntity do
      include ::Sipity::Conversions::ConvertToProcessingEntity

      context '.call' do
        it 'will call the underlying conversion method' do
          object = Models::Processing::Entity.new
          expect(described_class.call(object)).to eq(object)
        end
      end

      context '.convert_to_processing_entity' do
        it 'will be private' do
          object = double(to_processing_entity: 1234)
          expect { described_class.convert_to_processing_entity(object) }.
            to raise_error(NoMethodError, /private method `convert_to_processing_entity'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_processing_entity' do

        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_processing_entity)
        end

        it 'will return the object if it is a Processing::Entity' do
          object = Models::Processing::Entity.new
          expect(convert_to_processing_entity(object)).to eq(object)
        end

        context 'a Models::Work (because it will be processed)' do
          # This is poking knowledge over into the inner workings of Models::Work
          # but is a reasonable place to understand this.
          it 'will raise an exception if one has not been assigned' do
            object = Models::Work.new
            expect(object.processing_entity).to be_nil
            expect { convert_to_processing_entity(object) }.to raise_error(Exceptions::ProcessingEntityConversionError)
          end
          it 'will return the corresponding processing_entity' do
            object = Models::Work.new
            expected_processing_entity = object.build_processing_entity
            expect(convert_to_processing_entity(object)).to eq(expected_processing_entity)
          end
        end

        it 'will return the to_processing_entity if the object responds to the processing entity' do
          object = double(to_processing_entity: :processing_entity)
          expect(convert_to_processing_entity(object)).to eq(:processing_entity)
        end

        it 'will raise an error if it cannot convert' do
          object = double
          expect { convert_to_processing_entity(object) }.to raise_error(Exceptions::ProcessingEntityConversionError)
        end
      end
    end
  end
end
