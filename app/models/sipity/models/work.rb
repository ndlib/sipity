require 'sipity/models'
module Sipity
  module Models
    # The most basic of information required for generating a valid work.
    class Work < ActiveRecord::Base
      self.table_name = 'sipity_works'

      # @!attribute [rw] :processing_state The processing state of the work.
      #   @return [String]
      alias_attribute :processing_status, :processing_state

      has_many :collaborators, foreign_key: :work_id, dependent: :destroy
      has_many :additional_attributes, foreign_key: :work_id, dependent: :destroy
      has_many :attachments, foreign_key: :work_id, dependent: :destroy
      has_one :doi_creation_request, foreign_key: :work_id, dependent: :destroy
      has_many :access_rights, as: :entity, dependent: :destroy

      has_many :todo_item_states, as: :entity, dependent: :destroy
      deprecate :todo_item_states

      has_many :transient_answers, as: :entity, dependent: :destroy
      deprecate :transient_answers

      has_many :event_logs, as: :entity, class_name: 'Sipity::Models::EventLog'
      deprecate

      has_one :processing_entity, as: :proxy_for, dependent: :destroy, class_name: 'Sipity::Models::Processing::Entity'

      def to_processing_entity
        # This is a bit of a short cut, perhaps I should check if its persisted?
        # But I'll settle for this right now.
        processing_entity || fail(Exceptions::ProcessingEntityConversionError, self)
      end

      # TODO: Extract to TransientAnswer
      ALREADY_PUBLISHED = 'already_published'.freeze
      WILL_NOT_PUBLISH = 'will_not_publish'.freeze
      GOING_TO_PUBLISH = 'going_to_publish'.freeze
      DO_NOT_KNOW = 'do_not_know'.freeze

      # While this make look ridiculous, if I use an Array, the enum declaration
      # insists on persisting the value as the index instead of the key. While
      # this might make more sense from a storage standpoint, it is not as clear
      # and leverages a more opaque assumption.
      enum(
        work_publication_strategy:
        {
          WILL_NOT_PUBLISH => WILL_NOT_PUBLISH,
          ALREADY_PUBLISHED => ALREADY_PUBLISHED,
          GOING_TO_PUBLISH => GOING_TO_PUBLISH,
          DO_NOT_KNOW => DO_NOT_KNOW
        },
        work_type: WorkType.all_for_enum_configuration
      )

      after_initialize :set_default_work_type, if:  :new_record?

      private

      def set_default_work_type
        # HACK: Given that we are first working on the ETD submission, this
        # is an acceptable hack. However, as we move forward, it may not be.
        self.work_type ||= 'etd'
      end
    end
  end
end
