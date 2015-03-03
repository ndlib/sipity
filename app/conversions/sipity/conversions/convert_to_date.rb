module Sipity
  module Conversions
    # Exposes a conversion method to take an input and transform it into a
    # date.
    #
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToDate
      # A convenience method so that you don't need to include the conversion
      # module in your base class.
      #
      # @param input [Object] something coercable
      #
      # @return Date
      #
      # @see #convert_to_date
      def self.call(input)
        convert_to_date(input)
      end

      # Does its best to convert the input into a date.
      #
      # @example
      #   convert_to_date(1) { Date.today }
      #   => Date.today
      #
      # @param input [Object] something coercable
      #
      # @return Date
      # @yield If unable to parse you may yield the default
      #
      # @raise Exceptions::DateConversionError
      def convert_to_date(input)
        case input
        when Date, DateTime then input
        else
          Date.parse(input, false)
        end
      rescue TypeError, ArgumentError
        if block_given?
          yield
        else
          raise Exceptions::DateConversionError, input
        end
      end

      module_function :convert_to_date
      private_class_method :convert_to_date
      private :convert_to_date
    end
  end
end
