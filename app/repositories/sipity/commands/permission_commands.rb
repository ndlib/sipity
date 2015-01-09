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
      module_function

      # Responsible for finding the groups that are assigned the given acting_as for
      # the given entity's sip type.
      #
      # @raise Exception if for any of the given acting_as, no group could be found
      def grant_groups_permission_to_entity_for_acting_as!(entity:, acting_as:)
        Array.wrap(acting_as).each do |an_acting_as|
          group_names = Queries::PermissionQueries.group_names_for_entity_and_acting_as(acting_as: an_acting_as, entity: entity)
          Array.wrap(group_names).each do |group_name|
            group = Models::Group.find_or_create_by!(name: group_name)
            grant_permission_for!(entity: entity, acting_as: an_acting_as, actors: group)
          end
        end
      end
      public :grant_groups_permission_to_entity_for_acting_as!

      def grant_creating_user_permission_for!(entity:, user: nil, group: nil, actor: nil)
        # REVIEW: Does the constant even make sense on the data structure? Or
        #   is it more relevant here?
        acting_as = Models::Permission::CREATING_USER
        actors = [user, group, actor]
        grant_permission_for!(entity: entity, actors: actors, acting_as: acting_as)
      end
      public :grant_creating_user_permission_for!

      def grant_permission_for!(entity:, actors:, acting_as:)
        Array.wrap(actors).flatten.compact.each do |an_actor|
          Models::Permission.create!(entity: entity, actor: an_actor, acting_as: acting_as)
        end
      end
      private :grant_permission_for!
      private_class_method :grant_permission_for!
    end
    private_constant :PermissionCommands
  end
end
