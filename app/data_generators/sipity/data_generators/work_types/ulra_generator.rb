module Sipity
  module DataGenerators
    module WorkTypes
      # Responsible for generating the work types within the ETD.
      module UlraGenerator
        WORK_TYPE_NAMES = [
          Models::WorkType::ULRA_SUBMISSION
        ]
        PROCESSING_ROLE_NAMES = [
          Models::Role::CREATING_USER,
          Models::Role::ADVISING,
          Models::Role::DATA_OBSERVING,
          Models::Role::ULRA_REVIEWING
        ]
        ULRA_REVIEW_COMMITTEE_GROUP_NAME = 'ULRA Review Committee'
      end
    end
  end
end
