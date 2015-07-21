module Sipity
  # The module that contains various interactions with the underlying
  # persistence layer.
  module Commands
  end

  # The object you can use to interaction with the commands.
  class CommandRepository
    # I was using a delegator but was encountering a problem when attempting to
    # initialize a given form; I was losing the scope of the original
    # CommandRepository. The following method assures that I get all of the
    # Query modules included. It is possible that I will need
    # ActiveSupport::Concern
    QueryRepository.included_modules.each do |mod|
      include mod if mod.to_s =~ /Sipity::Queries::/
    end

    include Commands::WorkCommands
    include Commands::EventLogCommands
    include Commands::NotificationCommands
    include Commands::AdditionalAttributeCommands
    include Commands::PermissionCommands
    include Commands::TransientAnswerCommands
    include Commands::TodoListCommands
    include Commands::AccountProfileCommands
    include Commands::ProcessingCommands
    include Commands::AdministrativeScheduledActionCommands
  end
end
