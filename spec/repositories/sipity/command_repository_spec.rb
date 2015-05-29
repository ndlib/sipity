require 'rails_helper'

module Sipity
  RSpec.describe CommandRepository, type: :repository do
    subject { CommandRepository.new }

    context 'verifying method definition interaction' do
      let(:modules_to_check_for_method_collision) do
        # I'm concerned about the methods I've mixed in. There are several
        # modules already included.
        Sipity::CommandRepository.included_modules.select { |mod| mod.to_s =~ /\ASipity::/ }
      end

      it 'will have unique method names for its mixed in modules' do
        # NOTE: If you are making use of module mixin sequencing and the `super`
        #   method, this spec is going to fail. And if this spec fails, you
        #   broke the build. If you need to use `super` amongst the repository
        #   modules, lets have a discussion. There is likely a way around it.
        methods_defined_in_included_modules = []

        modules_to_check_for_method_collision.each do |mod|
          public_methods = mod.public_instance_methods
          private_methods = mod.private_instance_methods
          protected_methods = mod.protected_instance_methods

          intersection_of_methods = (public_methods + private_methods + protected_methods) & methods_defined_in_included_modules
          expect(intersection_of_methods).to be_empty
          methods_defined_in_included_modules += public_methods + private_methods + protected_methods
        end
      end
    end
  end
end
