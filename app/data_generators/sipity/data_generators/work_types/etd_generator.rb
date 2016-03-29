require 'active_support/core_ext/array/wrap'

module Sipity
  module DataGenerators
    module WorkTypes
      # Responsible for generating the work types within the ETD.
      module EtdGenerator
        WORK_TYPE_NAMES = [
          Models::WorkType::DOCTORAL_DISSERTATION,
          Models::WorkType::MASTER_THESIS
        ]
        GRADUATE_SCHOOL_REVIEWERS = 'Graduate School Reviewers'
        CATALOGERS = "Catalogers"
        DATA_ADMINISTRATORS = "Data Administrators"
      end
    end
  end
end
