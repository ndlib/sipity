module Sipity
  module Conversions
    # Exposes a conversion method to take an input and transform it into a
    # Sipity::Models::Work object.
    #
    # @see Sipity::Conversions for conventions regarding a conversion method
    module ConvertToWork
      # A convenience method so that you don't need to include the conversion
      # module in your base class.
      #
      # @param input [Object] something coercable
      #
      # @return [Sipity::Models::Work] (or something that followsto the Liskov
      #   Substitution Principle
      #   http://en.wikipedia.org/wiki/Liskov_substitution_principle)
      #
      # @see #convert_to_work
      def self.call(input)
        convert_to_work(input)
      end

      # Does its best to convert the input into a Sipity::Models::Work object.
      #
      # @param input [Object] something coercable
      #
      # @return [Sipity::Models::Work] (or something that followsto the Liskov
      #   Substitution Principle
      #   http://en.wikipedia.org/wiki/Liskov_substitution_principle)
      #
      # @raise Exceptions::WorkConversionError
      def convert_to_work(input)
        return input.to_work if input.respond_to?(:to_work)
        return input.work if input.respond_to?(:work)
        return input if input.is_a?(Models::Work)
        return Models::Work.find(input) if input.is_a?(String)
        return convert_to_work(input.proxy_for) if input.respond_to?(:proxy_for)
        raise Exceptions::WorkConversionError, input
      end

      module_function :convert_to_work
      private_class_method :convert_to_work
      private :convert_to_work
    end
  end
end
