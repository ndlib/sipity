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

      # Note the parity between this and the additional attributes.
      # I'm including the following map to remove a possible SQL
      # injection spot.
      #
      # Each key has a value that is a hash with two keys:
      # 1. `key`: - the `sipity_additional_attributes.key` field's value
      # 2. `join_as_table_name`: - for the purposes of the join, the
      #    table name we'll join as.
      #
      # We need the `join_as_table_name` so that we can join multiple
      # times to the same `sipity_additional_attributes` table.
      #
      # The cardinality is a rough assumption based on other forms.
      # Ideally, we'd have a data model that spoke about cardinality.
      # Alas, not quite time nor a place for that kind of work.
      ADDITIONAL_ATTRIBUTE_MAP = {
        "author_name" => { key: 'author_name', join_as_table_name: 'author_names' },
        "etd_submission_date" => { key: 'etd_submission_date', join_as_table_name: 'etd_submission_dates' },
        "program_name" => { key: 'program_name', join_as_table_name: 'program_names' }
      }

      self.default_additional_attributes = []

      ORDER_BY_OPTIONS = [
        'title', 'title DESC',
        'etd_submission_date', 'etd_submission_date DESC',
        'created_at', 'created_at DESC',
        'updated_at', 'updated_at DESC'
      ].freeze

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
      # @api private
      #
      # @param scope [ActiveRecord::Relation<proxy_for_types>] the query scope that we're actively building.
      # @return ActiveRecord::Relation<proxy_for_types>
      #
      # @note As much as I want this to be a scope that works for both
      # `SELECT COUNT` and `SELECT fields` type queries, the reality is
      # that ActiveRecord can't quite handle what we're throwing at it.
      #
      # So expect the returned scope to only work with `.all` and not
      # `.count`.  It appears that pagination works just fine.
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
        # With this short-circuit we preserve the ability to have
        # `.count` work on the scope.
        return scope if additional_attributes.empty?

        attr_table_name = Models::AdditionalAttribute.quoted_table_name
        work_table_name = scope.quoted_table_name
        select_fields = scope.column_names.map { |column_name| "#{work_table_name}.#{column_name}" }
        group_by_fields = select_fields.clone

        additional_attributes.each do |attribute|
          table_name = attribute.fetch(:join_as_table_name)
          key = attribute.fetch(:key)
          scope = scope.joins(
            %(LEFT OUTER JOIN #{attr_table_name} AS #{table_name} ON #{table_name}.work_id = #{work_table_name}.id AND #{table_name}.key = "#{key}")
          )

          # Given that we may have multiple values, we need to do some
          # concatenation so that we can preserve a single row per
          # work.
          select_fields << "GROUP_CONCAT(DISTINCT #{table_name}.value SEPARATOR ', ') AS #{key}"
        end

        # Given that each additional attribute could have multiple
        # values, we need to group by the attributes on the base
        # table.
        scope = scope.group(group_by_fields)

        # Note this must return the modified scope.
        scope.select(select_fields.join(", "))
      end

      attr_writer :user, :processing_state, :proxy_for_type, :work_area, :submission_window, :per

      # Doing our due diligence to santize parameters
      def additional_attributes=(input)
        @additional_attributes = Array(input).map do |attribute_name|
          ADDITIONAL_ATTRIBUTE_MAP.fetch(attribute_name)
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
