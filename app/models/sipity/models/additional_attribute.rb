require 'hesburgh/lib/html_scrubber'

module Sipity
  module Models
    # A rudimentary container for all (as of now string based) attributes
    # associated with the Sipity::Work
    # TODO: The underlying Sipity Database is mysql. If we moved to Postgresql we could move these in as a JSON field on Work.
    class AdditionalAttribute < ActiveRecord::Base
      # The format in which we will persist "well-formed" dates into
      # the additional attribute table.
      DATE_FORMAT = '%Y-%m-%d'.freeze

      # TODO: Create a map for input name to key and vice versa
      ABSTRACT_PREDICATE_NAME = 'abstract'.freeze
      ADMINISTRATIVE_UNIT_NAME = 'administrative_unit'.freeze
      AFFILIATION_PREDICATE_NAME = 'affiliation'.freeze
      ALTERNATE_TITLE_PREDICATE_NAME = 'alternate_title'.freeze
      ATTACHED_FILES_COMPLETION_STATE_PREDICATE_NAME = 'attached_files_completion_state'.freeze
      AUTHOR_NAME = 'author_name'.freeze
      AWARD_CATEGORY = 'award_category'.freeze
      BANNER_PROGRAM_CODE = 'banner_program_code'.freeze
      CATALOG_SYSTEM_NUMBER = 'catalog_system_number'.freeze
      CITATION_PREDICATE_NAME = 'citation'.freeze
      CITATION_STYLE_NAME = 'citation_style'.freeze
      CITATION_TYPE_PREDICATE_NAME = 'citationType'.freeze
      COLLABORATOR_PREDICATE_NAME = 'collaborator'.freeze
      COPYRIGHT_PREDICATE_NAME = 'copyright'.freeze
      COURSE_NAME_PREDICATE_NAME = 'course_name'.freeze
      COURSE_NUMBER_PREDICATE_NAME = 'course_number'.freeze
      DEFENSE_DATE_PREDICATE_NAME = 'defense_date'.freeze
      DEGREE_PREDICATE_NAME = 'degree'.freeze
      DOI_PREDICATE_NAME = 'identifier.doi'.freeze
      ETD_REVIEWER_SIGNOFF_DATE = 'ETD_REVIEWER_SIGNOFF_DATE'.freeze
      ETD_SUBMISSION_DATE = 'etd_submission_date'.freeze
      EXPECTED_GRADUATION_TERM = 'expected_graduation_term'.freeze
      IS_AN_AWARD_WINNER = 'is_an_award_winner'.freeze
      LANGUAGE = 'language'.freeze
      MAJORS = 'majors'.freeze
      MINORS = 'minors'.freeze
      OCLC_NUMBER = 'oclc_number'.freeze
      OTHER_RESOURCES_CONSULTED_PREDICATE_NAME = 'other_resources_consulted'.freeze
      PRIMARY_COLLEGE_PREDICATE_NAME = 'primary_college'.freeze
      PROGRAM_NAME_PREDICATE_NAME = 'program_name'.freeze
      PROJECT_URL_PREDICATE_NAME = 'project_url'.freeze
      PUBLICATION_DATE_PREDICATE_NAME = 'publicationDate'.freeze
      PUBLICATION_NAME_PREDICATE_NAME = 'publication_name'.freeze
      PUBLICATION_STATUS_OF_SUBMISSION = 'publication_status_of_submission'.freeze
      PUBLISHER_PREDICATE_NAME = 'publisher'.freeze
      RESOURCES_CONSULTED_NAME = 'resources_consulted'.freeze
      SPATIAL_COVERAGE = 'spatial_coverage'.freeze
      SUBJECT = 'subject'.freeze
      SUBMITTED_FOR_PUBLICATION = 'submitted_for_publication'.freeze
      TEMPORAL_COVERAGE = 'temporal_coverage'.freeze
      UNDERCLASS_LEVEL = 'underclass_level'.freeze
      USE_OF_LIBRARY_RESOURCES_PREDICATE_NAME = 'use_of_library_resources'.freeze
      WORK_PATENT_STRATEGY = 'work_patent_strategy'.freeze
      WORK_PUBLICATION_STRATEGY = 'work_publication_strategy'.freeze

      self.table_name = 'sipity_additional_attributes'
      belongs_to :work, foreign_key: 'work_id'

      enum(
        key: {
          ABSTRACT_PREDICATE_NAME => ABSTRACT_PREDICATE_NAME,
          ADMINISTRATIVE_UNIT_NAME => ADMINISTRATIVE_UNIT_NAME,
          AFFILIATION_PREDICATE_NAME => AFFILIATION_PREDICATE_NAME,
          ALTERNATE_TITLE_PREDICATE_NAME => ALTERNATE_TITLE_PREDICATE_NAME,
          ATTACHED_FILES_COMPLETION_STATE_PREDICATE_NAME => ATTACHED_FILES_COMPLETION_STATE_PREDICATE_NAME,
          AUTHOR_NAME => AUTHOR_NAME,
          AWARD_CATEGORY => AWARD_CATEGORY,
          BANNER_PROGRAM_CODE => BANNER_PROGRAM_CODE,
          CATALOG_SYSTEM_NUMBER => CATALOG_SYSTEM_NUMBER,
          CITATION_PREDICATE_NAME => CITATION_PREDICATE_NAME,
          CITATION_STYLE_NAME => CITATION_STYLE_NAME,
          CITATION_TYPE_PREDICATE_NAME => CITATION_TYPE_PREDICATE_NAME,
          COLLABORATOR_PREDICATE_NAME => COLLABORATOR_PREDICATE_NAME,
          COPYRIGHT_PREDICATE_NAME => COPYRIGHT_PREDICATE_NAME,
          COURSE_NAME_PREDICATE_NAME => COURSE_NAME_PREDICATE_NAME,
          COURSE_NUMBER_PREDICATE_NAME => COURSE_NUMBER_PREDICATE_NAME,
          DEFENSE_DATE_PREDICATE_NAME => DEFENSE_DATE_PREDICATE_NAME,
          DEGREE_PREDICATE_NAME => DEGREE_PREDICATE_NAME,
          DOI_PREDICATE_NAME => DOI_PREDICATE_NAME,
          ETD_REVIEWER_SIGNOFF_DATE => ETD_REVIEWER_SIGNOFF_DATE,
          ETD_SUBMISSION_DATE => ETD_SUBMISSION_DATE,
          EXPECTED_GRADUATION_TERM => EXPECTED_GRADUATION_TERM,
          IS_AN_AWARD_WINNER => IS_AN_AWARD_WINNER,
          LANGUAGE => LANGUAGE,
          MAJORS => MAJORS,
          MINORS => MINORS,
          OCLC_NUMBER => OCLC_NUMBER,
          OTHER_RESOURCES_CONSULTED_PREDICATE_NAME => OTHER_RESOURCES_CONSULTED_PREDICATE_NAME,
          PRIMARY_COLLEGE_PREDICATE_NAME => PRIMARY_COLLEGE_PREDICATE_NAME,
          PROGRAM_NAME_PREDICATE_NAME => PROGRAM_NAME_PREDICATE_NAME,
          PROJECT_URL_PREDICATE_NAME => PROJECT_URL_PREDICATE_NAME,
          PUBLICATION_DATE_PREDICATE_NAME => PUBLICATION_DATE_PREDICATE_NAME,
          PUBLICATION_NAME_PREDICATE_NAME => PUBLICATION_NAME_PREDICATE_NAME,
          PUBLICATION_STATUS_OF_SUBMISSION => PUBLICATION_STATUS_OF_SUBMISSION,
          PUBLISHER_PREDICATE_NAME => PUBLISHER_PREDICATE_NAME,
          RESOURCES_CONSULTED_NAME => RESOURCES_CONSULTED_NAME,
          SPATIAL_COVERAGE => SPATIAL_COVERAGE,
          SUBJECT => SUBJECT,
          SUBMITTED_FOR_PUBLICATION => SUBMITTED_FOR_PUBLICATION,
          TEMPORAL_COVERAGE => TEMPORAL_COVERAGE,
          UNDERCLASS_LEVEL => UNDERCLASS_LEVEL,
          USE_OF_LIBRARY_RESOURCES_PREDICATE_NAME => USE_OF_LIBRARY_RESOURCES_PREDICATE_NAME,
          WORK_PATENT_STRATEGY => WORK_PATENT_STRATEGY,
          WORK_PUBLICATION_STRATEGY => WORK_PUBLICATION_STRATEGY
        }
      )

      # The predicate definitions are nearby, so that is why I'm providing the
      # lookup container.
      def self.scrubber_for(predicate_name:, container: Hesburgh::Lib::HtmlScrubber)
        return container.build_inline_scrubber if predicate_name.to_s =~ /title\Z/
        container.build_block_scrubber
      end
    end
  end
end
