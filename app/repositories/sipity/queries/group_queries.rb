module Sipity
  module Queries
    module GroupQueries
      def roles_for_entity_and_group_name(options = {})
        Models::Permission.where(options.slice(:role, :entity))
      end
      module_function :roles_for_entity_and_group_name
      public :roles_for_entity_and_group_name

      def group_names_for(options = {})
        roles_for_entity_and_group_name(options).collect!{|p|Sipity::Models::Group.find(p.actor_id).name}
      end
      module_function :group_names_for
      public :group_names_for
    end
  end
end
