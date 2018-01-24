require 'active_support/core_ext/array/wrap'

module Sipity
  module Services
    # Responsible for managing the relationship between a work and it's collaborators
    # - Removing collaborators that are not associated with the work
    # - Assigning permission to those reviewing the work
    # - Removing permission to those that shifted from review to non-review role
    class ManageCollaborators
      # @api public
      def self.manage_collaborators_for(work:, collaborators:, repository:)
        new(work: work, collaborators: collaborators, repository: repository).manage_collaborators!
      end

      # @api public
      def self.assign_collaborators_to(work:, collaborators:, repository:)
        new(work: work, collaborators: collaborators, repository: repository).assign_given_collaborators!
      end

      def initialize(work:, collaborators:, repository:)
        self.work = work
        self.collaborators = collaborators
        self.repository = repository
      end

      attr_reader :work, :collaborators, :repository

      def manage_collaborators!
        remove_orphaned_collaborators!
        assign_given_collaborators!
      end

      def assign_given_collaborators!
        collaborators.each do |collaborator|
          collaborator.work_id = work.id
          collaborator.save!
          if collaborator.responsible_for_review?
            assign_reviewing_permission_to(collaborator: collaborator)
          else
            revoke_reviewing_permission_from(collaborator: collaborator)
          end
        end
      end

      private

      def remove_orphaned_collaborators!
        collaborators_table = Models::Collaborator.arel_table
        Models::Collaborator.where(
          collaborators_table[:work_id].eq(work.id).and(
            collaborators_table[:id].not_in(collaborators.flat_map(&:id))
          )
        ).destroy_all
      end

      def assign_reviewing_permission_to(collaborator:)
        create_sipity_user_from(netid: collaborator.netid, email: collaborator.email) do |user|
          change_processing_actor_proxy(from_proxy: collaborator, to_proxy: user)
          # TODO: This cannot be the assumed role for the :acting_as; I wonder if it would make sense
          # to dilineate roles on the contributor and roles in the system?
          repository.grant_permission_for!(actors: user, entity: work, acting_as: Models::Role::ADVISING)
        end
      end

      def revoke_reviewing_permission_from(collaborator:)
        actors = [collaborator]
        # Because of the odd relationship between collaborators and users (eg. Collaborators need not be signed into the
        # system, nor may not exist), we need to disassociate either user or collaborator from this
        actors << User.find_by(username: collaborator.netid) if collaborator.netid?
        repository.revoke_permission_for!(actors: actors.compact, entity: work, acting_as: Models::Role::ADVISING)
      end

      # In an effort to preserve processing actors, I want to expose a mechanism
      # for transfering processing actors to another proxy.
      #
      # This method arises as we consider the scenario in which someone approves
      # on behalf of a non-User collaborator (i.e. someone that has an email
      # address). Then the collaborator is changed such that a user is created.
      def change_processing_actor_proxy(from_proxy:, to_proxy:)
        return unless from_proxy.respond_to?(:processing_actor) && from_proxy.processing_actor.present?
        from_proxy.processing_actor.update(proxy_for: to_proxy)
      end

      def create_sipity_user_from(netid:, email: nil)
        return false unless netid.present?
        # This assumes a valid NetID.
        user = User.find_or_create_by!(username: netid) do |u|
          u.email = email || default_email_for_netid(netid)
        end
        yield(user) if block_given?
        user
      end

      def default_email_for_netid(netid)
        "#{netid}@nd.edu"
      end

      attr_writer :work, :repository

      def collaborators=(input)
        @collaborators = Array.wrap(input)
      end
    end
  end
end
