module Sipity
  module Conversions
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToRole
      def self.call(input)
        convert_to_role(input)
      end

      def convert_to_role(input)
        return input if input.is_a?(Models::Role)
        case input
        when String, Symbol then
          return Models::Role.find_or_create_by!(name: input)
        end
        fail Exceptions::RoleConversionError, input
      rescue ActiveRecord::RecordInvalid, ArgumentError
        raise Exceptions::RoleConversionError, input
      end

      module_function :convert_to_role
      private_class_method :convert_to_role
      private :convert_to_role
    end
  end
end
