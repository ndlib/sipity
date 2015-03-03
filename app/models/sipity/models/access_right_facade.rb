module Sipity
  module Models
    # Responsible for providing a bridge for managing an AccessRight indirectly.
    # That is to say, I don't want to create AccessRights for everything only
    # as needed and finalized.
    #
    # This behavior is achievable by way of ActiveRecord tomfoolery (i.e. a
    # find_by_sql or some such thing that joins multiple models but pushes it
    # onto a single ActiveRecord object). But that could be confusing.
    class AccessRightFacade
      def initialize(accessible_object)
        self.accessible_object = accessible_object
      end

      delegate :to_param, :id, :persisted?, :to_s, to: :@accessible_object
      delegate :access_right_code, :release_date, to: :access_right_object
      alias_method :entity_id, :id
      attr_reader :entity_type

      private

      include Conversions::ConvertToPolymorphicType
      def accessible_object=(object)
        @entity_type = convert_to_polymorphic_type(object)
        @accessible_object = object
      end

      def access_right_object
        @access_right_object ||= Models::AccessRight.find_or_initialize_by(entity_id: entity_id, entity_type: entity_type)
      end
    end
  end
end
