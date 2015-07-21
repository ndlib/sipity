module Sipity
  # The module that contains the various query submodules
  module Queries
  end
  # Defines and exposes the query methods for interacting with the public API of
  # the persistence layer.
  class QueryRepository
    include Queries::AccountProfileQueries
    include Queries::AdditionalAttributeQueries
    include Queries::AttachmentQueries
    include Queries::CollaboratorQueries
    include Queries::CommentQueries
    include Queries::EventLogQueries
    include Queries::NotificationQueries
    include Queries::ProcessingQueries
    include Queries::SimpleControlledVocabularyQueries
    include Queries::SubmissionWindowQueries
    include Queries::WorkAreaQueries
    include Queries::WorkQueries
    include Queries::AdministrativeScheduledActionQueries
  end
end
