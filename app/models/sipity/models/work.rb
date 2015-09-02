module Sipity
  module Models
    # The most basic of information required for generating a valid work.
    class Work < ActiveRecord::Base
      self.table_name = 'sipity_works'
      self.primary_key = :id
      paginates_per 15

      has_many :collaborators, foreign_key: :work_id, dependent: :destroy
      has_many :additional_attributes, foreign_key: :work_id, dependent: :destroy
      has_many :attachments, foreign_key: :work_id, dependent: :destroy
      has_one :access_right, as: :entity, dependent: :destroy
      has_many :event_logs, as: :entity, class_name: 'Sipity::Models::EventLog'
      has_one :work_submission, dependent: :destroy

      delegate :submission_window, :work_area, to: :work_submission, allow_nil: true

      include Conversions::SanitizeHtml
      def to_s
        remove_para_tag(sanitize_html(title))
      end

      Processing.configure_as_a_processible_entity(self)
      alias_attribute :processing_status, :processing_state

      enum(work_type: WorkType.all_for_enum_configuration)

      after_initialize :set_default_work_type, if: :new_record?

      private

      def set_default_work_type
        # HACK: Given that we are first working on the ETD submission, this
        # is an acceptable hack. However, as we move forward, it may not be.
        self.work_type ||= 'doctoral_dissertation'
      end
    end
  end
end
