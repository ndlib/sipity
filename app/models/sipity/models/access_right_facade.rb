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
      def initialize(accessible_object, work:, translator: default_translator)
        self.accessible_object = accessible_object
        self.work = work
        self.translator = translator
      end

      delegate :to_param, :id, :persisted?, :to_s, to: :@accessible_object
      delegate :access_right_code, :release_date, to: :access_right_object
      alias entity_id id
      attr_reader :entity_type
      attr_reader :accessible_object, :work
      private :accessible_object, :work

      def translate(object, scope: default_translation_scope, subject: accessible_object, predicate: 'label')
        translator.call(scope: scope, subject: subject, object: object, predicate: predicate)
      end

      def accessible_object_type
        return accessible_object.predicate_name.titleize if accessible_object.respond_to?(:predicate_name)
        human_model_name
      end

      delegate :model_name, to: :entity_type

      def human_model_name
        model_name.human
      end

      def access_url
        PowerConverter.convert(accessible_object, to: :access_url)
      end

      private

      attr_accessor :translator

      def default_translation_scope
        'access_rights'
      end

      def default_translator
        Controllers::TranslationAssistantForPolymorphicType
      end

      def accessible_object=(object)
        @entity_type = PowerConverter.convert(object, to: :polymorphic_type)
        @accessible_object = object
      end

      include Conversions::ConvertToWork
      def work=(work)
        @work = convert_to_work(work)
      end

      def access_right_object
        @access_right_object ||= begin
          access_right = Models::AccessRight.find_or_initialize_by(entity_id: entity_id, entity_type: entity_type)
          assign_work_access_right_code_if_none_is_set(access_right)
          access_right
        end
      end

      def assign_work_access_right_code_if_none_is_set(access_right)
        return true if access_right.access_right_code?
        work_access_right = Models::AccessRight.find_or_initialize_by(entity_id: work.id, entity_type: PowerConverter.convert(work, to: :polymorphic_type))
        access_right.access_right_code = work_access_right.access_right_code
        access_right.release_date = work_access_right.release_date
        access_right
      end
    end
  end
end
