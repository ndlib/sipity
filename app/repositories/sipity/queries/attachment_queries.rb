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
