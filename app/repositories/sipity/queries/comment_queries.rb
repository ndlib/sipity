module Sipity
  module Queries
    # Queries
    module CommentQueries
      def find_comments_for_work(work:)
        entity = entity_for_work(work: work)
        comments = comments(entity: entity)
        format_comments(comments: comments)
      end

      private

      def entity_for_work(work:)
        Conversions::ConvertToProcessingEntity.call(work)
      end

      def comments(entity:)
        Sipity::Models::Processing::Comment.where(entity_id: entity)
      end

      def actor(comment:)
        Sipity::Models::Processing::Actor.find(comment.actor_id)
      end

      def format_comments(comments:)
        formatted_comments = []
        formatted_comment = {}
        comments.each do |comment|
          formatted_comment[:commenter] = actor(comment: comment).proxy_for.name
          formatted_comment[:comment] = comment.comment
          formatted_comments << formatted_comment
        end
        formatted_comments
      end
    end
  end
end
