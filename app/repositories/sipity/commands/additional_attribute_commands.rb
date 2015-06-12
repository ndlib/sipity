module Sipity
  # :nodoc:
  module Commands
    # Commands
    module AdditionalAttributeCommands
      def update_work_attribute_values!(work:, key:, values:)
        input_values = Array.wrap(values)
        existing_values = Queries::AdditionalAttributeQueries.work_attribute_values_for(work: work, key: key)
        create_work_attribute_values!(work: work, key: key, values: (input_values - existing_values))
        destroy_work_attribute_values!(work: work, key: key, values: (existing_values - input_values))
      end
      module_function :update_work_attribute_values!
      public :update_work_attribute_values!

      def create_work_attribute_values!(work:, key:, values:)
        Array.wrap(values).each do |value|
          Models::AdditionalAttribute.create!(work: work, key: key, value: value) if value.present?
        end
      end
      module_function :create_work_attribute_values!
      public :create_work_attribute_values!

      def destroy_work_attribute_values!(work:, key:, values:)
        values_to_destroy = Array.wrap(values)
        return true unless values_to_destroy.present?
        Models::AdditionalAttribute.where(work: work, key: key, value: values_to_destroy).destroy_all
      end

      module_function :destroy_work_attribute_values!
      public :destroy_work_attribute_values!
    end
  end
end
