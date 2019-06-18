require 'active_support/core_ext/array/wrap'

module Sipity
  # :nodoc:
  module Commands
    # Commands
    module AdministrativeCommands
      # @api public
      #
      # Responsible for:
      #   1. Ensuring that the given :group_name exists.
      #   2. Ensuring that each user by :username exists.
      #   3. Ensuring that each of the given users has membership in the given group
      #   4. If :force_membership_to_these_usernames is true, then ensure that no other
      #      no other users have membership in the given group.
      #
      # @param [String] group_name - The name of the Sipity::Models::Group to which
      #    we'll be adding group members
      # @param [Array<String>] usernames - The name of the users
      # @param [Boolean] force_membership_to_these_usernames - If true, only the given
      #    users will have membership in the given group. If false, the given users
      #    will be appended to the membership of the group.
      #
      # @return void
      def set_group_membership(group_name:, usernames: [], force_membership_to_these_usernames: false)
        # Find or create the group by name
        group = Sipity::Models::Group.find_or_create_by!(name: group_name)
        user_ids = Array.wrap(usernames).map do |username|
          user = User.find_or_create_by!(username: username)
          group.group_memberships.find_or_create_by!(user: user)
          user.id
        end
        return true unless force_membership_to_these_usernames
        group.group_memberships.each do |group_membership|
          group_membership.destroy unless user_ids.include?(group_membership.user_id)
        end
      end
    end
  end
end
