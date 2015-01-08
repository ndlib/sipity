module Sipity
  module Queries
    # Queries to get group/roles related queries
    module GroupQueries
      def roles_for_entity_and_group_name(options = {})
        Models::Permission.where(options.slice(:role, :entity)).pluck(:role)
      end
      module_function :roles_for_entity_and_group_name
      public :roles_for_entity_and_group_name

      def group_names_for(options = {})
        roles_array = roles_for_entity_and_group_name(options)
        return [] if roles_array.empty?
        roles_array.map { |role_name| Queries::PermissionQueries.permission_for(role: role_name) }
      end
      module_function :group_names_for
      public :group_names_for
    end
  end
end
