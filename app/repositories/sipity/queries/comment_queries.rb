module Sipity
  module Queries
    # Queries
    module CommentQueries
      def find_comments_for_work(work:)
        entity = Conversions::ConvertToProcessingEntity.call(work)
        Sipity::Models::Processing::Comment.where(entity_id: entity)
      end
    end
  end
end
