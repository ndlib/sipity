require 'sipity/models'
module Sipity
  module Models
    # A rudimentary container for all (as of now string based) attributes
    # associated with the Sipity::Work
    class AdditionalAttribute < ActiveRecord::Base
      # TODO: Create a map for input name to key and vice versa
      DOI_PREDICATE_NAME = 'identifier.doi'.freeze
      CITATION_PREDICATE_NAME = 'citation'.freeze
      CITATION_TYPE_PREDICATE_NAME = 'citationType'.freeze
      PUBLISHER_PREDICATE_NAME = 'publisher'.freeze
      PUBLICATION_DATE_PREDICATE_NAME = 'publicationDate'.freeze
      ABSTRACT_PREDICATE_NAME = 'abstract'.freeze
      DEFENSE_DATE_PREDICATE_NAME = 'defense_date'.freeze
      DISCIPLINE_PREDICATE_NAME = 'discipline'.freeze
      DEGREE_PREDICATE_NAME = 'degree'.freeze
      PROGRAM_PREDICATE_NAME = 'program_name'.freeze
      ALTERNATE_TITLE_PREDICATE_NAME = 'alternate_title'.freeze
      COPYRIGHT_PREDICATE_NAME = 'copyright'.freeze
      SUBJECT = 'subject'.freeze
      LANGUAGE = 'language'.freeze
      TEMPORAL_COVERAGE = 'temporal_coverage'.freeze
      SPATIAL_COVERAGE = 'spatial_coverage'.freeze

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
          PROGRAM_PREDICATE_NAME => PROGRAM_PREDICATE_NAME,
          DISCIPLINE_PREDICATE_NAME => DISCIPLINE_PREDICATE_NAME,
          ALTERNATE_TITLE_PREDICATE_NAME => ALTERNATE_TITLE_PREDICATE_NAME,
          COPYRIGHT_PREDICATE_NAME => COPYRIGHT_PREDICATE_NAME,
          SUBJECT => SUBJECT,
          LANGUAGE => LANGUAGE,
          TEMPORAL_COVERAGE => TEMPORAL_COVERAGE,
          SPATIAL_COVERAGE => SPATIAL_COVERAGE
        }
      )
    end
  end
end
