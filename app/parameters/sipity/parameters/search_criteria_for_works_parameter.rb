module Sipity
  module Parameters
    # A coordination parameter to help build the search criteria for works.
    class SearchCriteriaForWorksParameter
      ATTRIBUTE_NAMES = [:page, :order, :proxy_for_type, :processing_state, :submission_window, :user, :work_area, :per, :additional_attributes, :q].freeze
      DEFAULT_ATTRIBUTE_NAMES = ATTRIBUTE_NAMES.map { |a| "default_#{a}".to_sym }.freeze

      class_attribute(*DEFAULT_ATTRIBUTE_NAMES, instance_writer: false)

      self.default_page = 1
      self.default_per = 8
      self.default_user = nil
      self.default_proxy_for_type = Models::Work
      self.default_processing_state = nil
      self.default_work_area = nil
      self.default_submission_window = nil
      self.default_q = nil
      self.default_order = 'title'.freeze
      self.default_additional_attributes = ["author_name", "submission_date"].freeze
      ORDER_BY_OPTIONS = ['title', 'title DESC', 'created_at', 'created_at DESC', 'updated_at', 'updated_at DESC'].freeze

      def self.order_options_for_select
        ORDER_BY_OPTIONS
      end

      def initialize(**keywords)
        ATTRIBUTE_NAMES.each do |attribute_name|
          send("#{attribute_name}=", keywords.fetch(attribute_name) { send("default_#{attribute_name}") })
        end
      end

      attr_reader(*ATTRIBUTE_NAMES)

      ATTRIBUTE_NAMES.each do |method_name|
        define_method "#{method_name}?" do
          instance_variable_get("@#{method_name}").present?
        end
      end

      ##
      #
      # @param scope [ActiveRecord::Relation<proxy_for_types>] the query scope that we're actively building.
      # @return ActiveRecord::Relation<proxy_for_types>
      def apply_and_return(scope:)
        scope = scope.order(order) if order?
        scope = scope.page(page) if page?
        # For Kaminari to work with `.per` page, there is a method call temporal
        # dependency. First you must call `.page` then you may call `.per`.
        scope = scope.per(per) if per? && page?
        apply_and_return_additional_attributes_to(scope: scope)
      end

      private

      # And due to the nature of ActiveRecord, fields added to the
      # SQL's SELECT statement are part of the data structure of the
      # object.  In this way we can create a view of a work object
      # that includes additional attributes.
      #
      # @note At this time, the implementation assumes that there will
      # be only one row per additional attribute.  If that were to
      # change, we'd need to craft a better approach.  Not sure what
      # that better approach would be, but I'm sure it would depend on
      # the product owner requirements for those fields.
      def apply_and_return_additional_attributes_to(scope:)
        attr_table_name = Models::AdditionalAttribute.quoted_table_name
        work_table_name = scope.quoted_table_name
        select_fields = ["#{work_table_name}.*"]

        additional_attributes.each do |attribute|
          table_name = attribute.to_s.pluralize
          scope = scope.joins(
            %(LEFT OUTER JOIN #{attr_table_name} AS #{table_name} ON #{table_name}.work_id = #{work_table_name}.id AND #{table_name}.key = "#{attribute}")
          )
          select_fields << "#{table_name}.value AS #{attribute}"
        end

        scope.select(select_fields.join(", "))
        scope
      end

      attr_writer :user, :processing_state, :proxy_for_type, :work_area, :submission_window, :per

      # Doing our due diligence to santize parameters
      def additional_attributes=(input)
        @additional_attributes = Array(input).map do |attribute_name|
          Models::AdditionalAttribute.sanitize_sql_for_conditions(attribute_name.to_s)
        end
      end

      def page=(input)
        @page = input.to_i
      end

      def order=(input)
        @order = ORDER_BY_OPTIONS.include?(input) ? input : default_order
      end

      def q=(input)
        @q = input.present? ? input.to_s : nil
      end
    end
  end
end
