require 'active_support/core_ext/array/wrap'

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
      def grant_creating_user_permission_for!(entity:, user: nil, group: nil, actor: nil)
        # REVIEW: Does the constant even make sense on the data structure? Or
        #   is it more relevant here?
        acting_as = Models::Role::CREATING_USER
        actors = [user, group, actor]
        grant_permission_for!(entity: entity, actors: actors, acting_as: acting_as)
      end

      # @api public
      def grant_permission_for!(entity:, actors:, acting_as:)
        Array.wrap(actors).flatten.compact.each do |an_actor|
          grant_processing_permission_for!(entity: entity, actor: an_actor, role: acting_as)
        end
      end

      # @api private
      def grant_processing_permission_for!(entity:, actor:, role:)
        Services::GrantProcessingPermission.call(entity: entity, actor: actor, role: role)
      end

      # @api public
      def revoke_permission_for!(entity:, actors:, acting_as:)
        Array.wrap(actors).flatten.compact.each do |an_actor|
          revoke_processing_permission_for!(entity: entity, actor: an_actor, role: acting_as)
        end
      end

      # @api private
      def revoke_processing_permission_for!(entity:, actor:, role:)
        Services::RevokeProcessingPermission.call(entity: entity, actor: actor, role: role)
      end
    end
  end
end
