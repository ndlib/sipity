require 'active_support/core_ext/array/wrap'

module Sipity
  module Services
    # Service object that handles the business logic of granting permission.
    class ActionTakenOnEntity
      def self.register(**keywords)
        new(**keywords).register
      end

      def self.unregister(**keywords)
        new(**keywords).unregister
      end

      # TODO: Subject and entity are redundant. Rename parameter to :subject to
      #   reflect the more ambiguous nature of the action's response.
      def initialize(entity:, action:, requested_by:, **keywords)
        self.subject = entity
        self.entity = entity
        self.action = action
        self.requesting_actor = requested_by
        self.on_behalf_of_actor = keywords.fetch(:on_behalf_of) { requesting_actor }
        self.repository = keywords.fetch(:repository) { default_repository }
        self.processing_hooks = keywords.fetch(:processing_hooks) { default_processing_hooks }

        # TODO: Push this down to the database?
        self.also_register_as = keywords.fetch(:also_register_as) { [] }
      end
      attr_reader :entity, :action, :requesting_actor, :on_behalf_of_actor, :also_register_as, :subject

      def register
        log_the_action
        registered_action = register_action_on_entity(action: action)
        add_actions_that_should_also_be_registered
        deliver_notifications_for(registered_action: registered_action)
      end

      def unregister
        # TODO: Tease apart the requested_by and on_behalf_of
        Models::Processing::EntityActionRegister.where(
          strategy_action_id: action.id,
          entity_id: entity.id,
          requested_by_actor_id: requesting_actor.id,
          on_behalf_of_actor_id: on_behalf_of_actor.id
        ).destroy_all
      end

      private

      def add_actions_that_should_also_be_registered
        also_register_as.each { |action| register_action_on_entity(action: action) }
      end

      def register_action_on_entity(action:)
        processing_hooks.call(
          action: action, requested_by: requesting_actor, on_behalf_of: on_behalf_of_actor, entity: entity, repository: repository
        )
        create_entity_action_registry_entry!(action: action)
      end

      def create_entity_action_registry_entry!(action:)
        # TODO: Tease apart the requested_by and on_behalf_of
        Models::Processing::EntityActionRegister.create!(
          strategy_action_id: action.id,
          entity_id: entity.id,
          requested_by_actor_id: requesting_actor.id,
          on_behalf_of_actor_id: on_behalf_of_actor.id,
          subject_id: subject.id,
          subject_type: PowerConverter.convert(subject, to: :polymorphic_type)
        )
      end

      def log_the_action
        # TODO: This is a cheat, in that I am assuming the request actor is a user.
        repository.log_event!(entity: entity, requested_by: requesting_actor.proxy_for, event_name: event_name)
      end

      def deliver_notifications_for(registered_action:)
        repository.deliver_notification_for(
          scope: action, the_thing: registered_action, requested_by: requesting_actor, on_behalf_of: on_behalf_of_actor
        )
      end

      def event_name
        "#{action.name}/submit"
      end

      attr_accessor :repository

      def default_repository
        CommandRepository.new
      end

      attr_accessor :processing_hooks
      def default_processing_hooks
        ProcessingHooks
      end

      include Conversions::ConvertToProcessingEntity
      def entity=(entity_like_object)
        @entity = convert_to_processing_entity(entity_like_object)
      end

      def subject=(input)
        # Guard!
        PowerConverter.convert(input, to: :polymorphic_type)
        @subject = input
      end

      include Conversions::ConvertToProcessingAction
      def action=(object)
        @action = convert_to_processing_action(object, scope: entity)
      end

      def also_register_as=(input)
        @also_register_as = Array.wrap(input).map { |an_action| convert_to_processing_action(an_action, scope: entity) }
      end

      def requesting_actor=(actor_like_object)
        @requesting_actor = convert_to_processing_actor(actor_like_object)
      end

      include Conversions::ConvertToProcessingActor
      def on_behalf_of_actor=(actor_like_object)
        @on_behalf_of_actor = convert_to_processing_actor(actor_like_object)
      end
    end
  end
end
