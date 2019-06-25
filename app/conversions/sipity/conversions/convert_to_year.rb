module Sipity
  module Conversions
    # Exposes a conversion method to take an input and transform it into a
    # year.
    #
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToYear
      # A convenience method so that you don't need to include the conversion
      # module in your base class.
      #
      # @param input [Object] something coercable
      #
      # @return Integer
      #
      # @see #convert_to_year
      def self.call(input)
        convert_to_year(input)
      end

      # Does its best to convert the input into a year.
      #
      # @param input [Object] something coercable
      #
      # @return Integer
      def convert_to_year(input)
        return input if input.is_a?(Integer)
        return input.to_year if input.respond_to?(:to_year)
        return input.year if input.respond_to?(:year)
        return convert_to_year(input.to_date) if input.respond_to?(:to_date)
      rescue ArgumentError
        return input.to_i.zero? ? nil : input.to_i if input.respond_to?(:to_i)
      end

      module_function :convert_to_year
      private_class_method :convert_to_year
      private :convert_to_year
    end
  end
end
