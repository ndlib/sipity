module Sipity
  module Commands
    # Commands
    module CollaboratorCommands
      module_function

      # TODO: Consider moving these into the HeaderCommands
      def create_collaborators_for_header!(header:, collaborators:)
        collaborators.each do |collaborator|
          collaborator.header = header
          collaborator.save!
        end
      end
      public :create_collaborators_for_header!
    end
  end
end
