module Sipity
  # :nodoc:
  module Commands
    # Commands related to the permission model
    #
    # TODO: Need to come up with a better way of handling this. Exposing
    # module functions and instance methods is a bit insane. It works, but
    # increases coupling. Possible solution, module provides a means for
    # delegation to a proper class? The design goal is to provide a way for
    # accessing repository services in other contexts. So the question is:
    # How is that different from module functions and instance methods via
    # mixin? Something to think about.
    module PermissionCommands
      # Responsible for finding the groups that are assigned the given acting_as for
      # the given entity's work type.
      #
      # @raise Exception if for any of the given acting_as, no group could be found
      def grant_groups_permission_to_entity_for_acting_as!(entity:, acting_as:)
        # TODO: Extract this map of acting_as to groups; Will we need acting_as by
        #   work type?
        Array.wrap(acting_as).each do |an_acting_as|
          group_names = Queries::PermissionQueries.group_names_for_entity_and_acting_as(acting_as: an_acting_as, entity: entity)
          Array.wrap(group_names).each do |group_name|
            group = Models::Group.find_or_create_by!(name: group_name)
            grant_permission_for!(entity: entity, acting_as: an_acting_as, actors: group)
          end
        end
      end

      def grant_creating_user_permission_for!(entity:, user: nil, group: nil, actor: nil)
        # REVIEW: Does the constant even make sense on the data structure? Or
        #   is it more relevant here?
        acting_as = Models::Permission::CREATING_USER
        actors = [user, group, actor]
        grant_permission_for!(entity: entity, actors: actors, acting_as: acting_as)
      end

      def grant_permission_for!(entity:, actors:, acting_as:)
        Array.wrap(actors).flatten.compact.each do |an_actor|
          grant_deprecated_permission_for!(entity: entity, actor: an_actor, acting_as: acting_as)
          grant_processing_permission_for!(entity: entity, actor: an_actor, role: acting_as)
        end
      end
      module_function :grant_permission_for!
      public :grant_permission_for!

      def grant_processing_permission_for!(_options = {})
        # processing_actor = Conversions::ConvertToProcessingActor.call(actor)
        # entity = Conversions::ConvertToProcessingEntity.call(entity)
        # role = Conversions::ConvertToRole.call(role)
      end
      module_function :grant_processing_permission_for!
      public :grant_processing_permission_for!

      def grant_deprecated_permission_for!(entity:, actor:, acting_as:)
        Models::Permission.create!(entity: entity, actor: actor, acting_as: acting_as)
      end
      module_function :grant_deprecated_permission_for!
      class << self
        deprecate :grant_deprecated_permission_for!
      end
      private :grant_deprecated_permission_for!
      deprecate :grant_deprecated_permission_for!
    end
  end
end
