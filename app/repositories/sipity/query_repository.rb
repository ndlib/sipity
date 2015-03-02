module Sipity
  # The module that contains the various query submodules
  module Queries
  end
  # Defines and exposes the query methods for interacting with the public API of
  # the persistence layer.
  class QueryRepository
    include Queries::WorkQueries
    include Queries::CitationQueries
    include Queries::DoiQueries
    include Queries::EventLogQueries
    include Queries::AccountPlaceholderQueries
    include Queries::AdditionalAttributeQueries
    include Queries::CollaboratorQueries
    include Queries::PermissionQueries
    include Queries::EnrichmentQueries
    include Queries::EventTriggerQueries
    include Queries::ProcessingQueries
    include Queries::AttachmentQueries
  end
end
