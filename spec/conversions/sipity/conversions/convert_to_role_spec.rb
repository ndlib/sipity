require 'spec_helper'

module Sipity
  module Conversions
    describe ConvertToRole do
      include ::Sipity::Conversions::ConvertToRole

      context '.call' do
        it 'will call the underlying conversion method' do
          object = double(to_role: 'Hello')
          expect { described_class.call(object) }.to raise_error(Exceptions::RoleConversionError)
        end
      end

      context '.convert_to_role' do
        it 'will be private' do
          object = double
          expect { described_class.convert_to_role(object) }.
            to raise_error(NoMethodError, /private method `convert_to_role'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_role' do

        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_role)
        end

        it "will raise exception even if object implements to_role" do
          object = double(to_role: 'Hello')
          expect { convert_to_role(object) }.to raise_error(Exceptions::RoleConversionError)
        end

        it "will find_or_create a valid role name" do
          object = Models::Role.valid_names.first
          expect(convert_to_role(object)).to be_a(Models::Role)
        end

        it "will raise exception if the name is invalid" do
          object = '__not_valid__'
          expect { convert_to_role(object) }.to raise_error(Exceptions::RoleConversionError)
        end
      end
    end
  end
end
