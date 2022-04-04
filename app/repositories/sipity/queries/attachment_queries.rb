module Sipity
  module Queries
    # Queries
    module AttachmentQueries
      # The permissable order options when querying
      ATTACHMENT_QUERY_ORDER_OPTIONS = {
        representative_first: 'is_representative_file DESC'.freeze,
        none: false
      }.freeze

      def work_attachments(work:, predicate_name: :all, order: :none)
        scope = Models::Attachment.includes(:work, :access_right).where(work_id: work.id)
        if predicate_name != :all
          scope = scope.where(predicate_name: predicate_name)
        end
        query_order = ATTACHMENT_QUERY_ORDER_OPTIONS.fetch(order)
        return scope unless query_order
        scope.order(query_order)
      end

      REPEATABLE_TERMINAL_ACTION = ['ingest_completed']
      def replaced_work_attachments(work:, predicate_name: :all, order: :none)
        # find the most recent ingest date
        proxies = Sipity::Models::Processing::Entity.where(proxy_for_id: work.id)
        proxy_id = proxies.first.id
        actions_to_test =  Models::Processing::StrategyAction.where(name: REPEATABLE_TERMINAL_ACTION)
        ingested = Models::Processing::EntityActionRegister.where(entity_id: proxy_id, strategy_action_id: actions_to_test)

        if ingested.present?
          # find the prior ingest date
          ingested_date = ingested.order(created_at: :desc).first.created_at
          # find attachment(s) for the work where the updated date is greater than the prior ingest date
          scope = Models::Attachment.includes(:work, :access_right).where(work_id: work.id).where('updated_at > ?', ingested_date)
        else
          # find attachment(s) for the work where the updated date is greater than the created date i.e. they have been changed at some point in time since they were added. 
          # Note: this shouldn't happen unless we are testing (i.e. we force something into ingested status and the logs don't show the info)
          scope = Models::Attachment.includes(:work, :access_right).where(work_id: work.id).where('updated_at > created_at')
        end

        if predicate_name != :all
          scope = scope.where(predicate_name: predicate_name)
        end
        query_order = ATTACHMENT_QUERY_ORDER_OPTIONS.fetch(order)
        return scope unless query_order
        scope.order(query_order)
      end

      def attachment_access_right(attachment:)
        attachment.access_right || attachment.work.access_right
      end

      def accessible_objects(work:, predicate_name: :all, order: :none)
        [work] + work_attachments(work: work, predicate_name: predicate_name, order: order)
      end

      def access_rights_for_accessible_objects_of(work:, predicate_name: :all, order: :none)
        accessible_objects(work: work, predicate_name: predicate_name, order: order).map do |object|
          Models::AccessRightFacade.new(object, work: work)
        end
      end

      def find_or_initialize_attachments_by(work:, pid:)
        Models::Attachment.find_or_initialize_by(work_id: work.id, pid: pid)
      end

      def representative_attachment_for(work:)
        Models::Attachment.where(work_id: work.id, is_representative_file: true).first
      end
    end
  end
end
