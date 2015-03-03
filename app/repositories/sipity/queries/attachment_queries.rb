module Sipity
  module Queries
    # Queries
    module AttachmentQueries
      def work_attachments(work:)
        Models::Attachment.includes(:work).where(work_id: work)
      end

      def accessible_objects(work:)
        [work] + work_attachments(work: work)
      end

      def access_rights_for_accessible_objects_of(work:)
        accessible_objects(work: work).map { |object| Models::AccessRightFacade.new(object) }
      end

      def find_or_initialize_attachments_by(work:, pid:)
        Models::Attachment.find_or_initialize_by(work_id: work.id, pid: pid)
      end

      def representative_attachment_for(work:)
        Models::Attachment.where(work_id: work.id, is_representative_file: true)
      end
    end
  end
end
