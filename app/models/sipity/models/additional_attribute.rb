module Sipity
  module Models
    # A rudimentary container for all (as of now string based) attributes
    # associated with the Sipity::Work
    class AdditionalAttribute < ActiveRecord::Base
      # The format in which we will persist "well-formed" dates into
      # the additional attribute table.
      DATE_FORMAT = '%Y-%m-%d'.freeze

      # TODO: Create a map for input name to key and vice versa
      DOI_PREDICATE_NAME = 'identifier.doi'.freeze
      CITATION_PREDICATE_NAME = 'citation'.freeze
      CITATION_TYPE_PREDICATE_NAME = 'citationType'.freeze
      PUBLISHER_PREDICATE_NAME = 'publisher'.freeze
      PUBLICATION_DATE_PREDICATE_NAME = 'publicationDate'.freeze
      ABSTRACT_PREDICATE_NAME = 'abstract'.freeze
      DEFENSE_DATE_PREDICATE_NAME = 'defense_date'.freeze
      DEGREE_PREDICATE_NAME = 'degree'.freeze
      PROGRAM_NAME_PREDICATE_NAME = 'program_name'.freeze
      ALTERNATE_TITLE_PREDICATE_NAME = 'alternate_title'.freeze
      COPYRIGHT_PREDICATE_NAME = 'copyright'.freeze
      SUBJECT = 'subject'.freeze
      LANGUAGE = 'language'.freeze
      TEMPORAL_COVERAGE = 'temporal_coverage'.freeze
      SPATIAL_COVERAGE = 'spatial_coverage'.freeze
      RESOURCE_CONSULTED_NAME = 'resource_consulted'.freeze
      CITATION_STYLE_NAME = 'citation_style'.freeze
      AWARD_CATEGORY = 'award_category'.freeze
      EXPECTED_GRADUATION_DATE = 'expected_graduation_date'.freeze
      MAJORS = 'majors'.freeze
      WORK_PATENT_STRATEGY = 'work_patent_strategy'.freeze
      WORK_PUBLICATION_STRATEGY = 'work_publication_strategy'.freeze
      AFFILIATION_PREDICATE_NAME = 'affiliation'.freeze
      ORGANIZATION_PREDICATE_NAME = 'organization'.freeze
      COLLABORATOR_PREDICATE_NAME = 'collaborator'.freeze
      ETD_SUBMISSION_DATE = 'etd_submission_date'.freeze
      ETD_REVIEWER_SIGNOFF_DATE = 'ETD_REVIEWER_SIGNOFF_DATE'.freeze
      OCLC_NUMBER = 'oclc_number'.freeze

      self.table_name = 'sipity_additional_attributes'
      belongs_to :work, foreign_key: 'work_id'

      enum(
        key: {
          DOI_PREDICATE_NAME => DOI_PREDICATE_NAME,
          CITATION_PREDICATE_NAME => CITATION_PREDICATE_NAME,
          CITATION_TYPE_PREDICATE_NAME => CITATION_TYPE_PREDICATE_NAME,
          PUBLISHER_PREDICATE_NAME => PUBLISHER_PREDICATE_NAME,
          PUBLICATION_DATE_PREDICATE_NAME => PUBLICATION_DATE_PREDICATE_NAME,
          ABSTRACT_PREDICATE_NAME => ABSTRACT_PREDICATE_NAME,
          DEFENSE_DATE_PREDICATE_NAME => DEFENSE_DATE_PREDICATE_NAME,
          DEGREE_PREDICATE_NAME => DEGREE_PREDICATE_NAME,
          PROGRAM_NAME_PREDICATE_NAME => PROGRAM_NAME_PREDICATE_NAME,
          ALTERNATE_TITLE_PREDICATE_NAME => ALTERNATE_TITLE_PREDICATE_NAME,
          COPYRIGHT_PREDICATE_NAME => COPYRIGHT_PREDICATE_NAME,
          SUBJECT => SUBJECT,
          LANGUAGE => LANGUAGE,
          TEMPORAL_COVERAGE => TEMPORAL_COVERAGE,
          SPATIAL_COVERAGE => SPATIAL_COVERAGE,
          RESOURCE_CONSULTED_NAME => RESOURCE_CONSULTED_NAME,
          CITATION_STYLE_NAME => CITATION_STYLE_NAME,
          AWARD_CATEGORY => AWARD_CATEGORY,
          EXPECTED_GRADUATION_DATE => EXPECTED_GRADUATION_DATE,
          MAJORS => MAJORS,
          WORK_PATENT_STRATEGY => WORK_PATENT_STRATEGY,
          WORK_PUBLICATION_STRATEGY => WORK_PUBLICATION_STRATEGY,
          AFFILIATION_PREDICATE_NAME => AFFILIATION_PREDICATE_NAME,
          ORGANIZATION_PREDICATE_NAME => ORGANIZATION_PREDICATE_NAME,
          COLLABORATOR_PREDICATE_NAME => COLLABORATOR_PREDICATE_NAME,
          ETD_SUBMISSION_DATE => ETD_SUBMISSION_DATE,
          ETD_REVIEWER_SIGNOFF_DATE => ETD_REVIEWER_SIGNOFF_DATE,
          OCLC_NUMBER => OCLC_NUMBER
        }
      )
    end
  end
end
