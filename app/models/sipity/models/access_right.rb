module Sipity
  module Models
    # Responsible for defining a range of time in which the access right is
    # in effect for a given entity.
    #
    # For the date range both the  enforcement start date and end date is
    # inclusive. That is to say Jan 1, 2015 to Feb 1, 2015 will be
    # all of January 2015 and the first day of February 2015.
    #
    # It is envisioned that the AccessRights will be contiguous non-overlapping
    # date ranges.
    class AccessRight < ActiveRecord::Base
      # @attr_accessor [Date] transition_date the date in which a transition
      #   would occur
      self.table_name = 'sipity_access_rights'

      OPEN_ACCESS = 'open_access'.freeze
      RESTRICTED_ACCESS = 'restricted_access'.freeze
      PRIVATE_ACCESS = 'private_access'.freeze
      EMBARGO_THEN_OPEN_ACCESS = 'embargo_then_open_access'.freeze

      enum(
        acccess_right_code: {
          OPEN_ACCESS => OPEN_ACCESS,
          RESTRICTED_ACCESS => RESTRICTED_ACCESS,
          PRIVATE_ACCESS => PRIVATE_ACCESS,
          EMBARGO_THEN_OPEN_ACCESS => EMBARGO_THEN_OPEN_ACCESS
        }
      )

      belongs_to :entity, polymorphic: true

      alias_attribute :release_date, :transition_date

      # What do I mean by this? I mean that these are the most basic codes that
      # we are capturing and persisting. There are others (e.g.
      # EMBARGO_THEN_OPEN_ACCESS) that require additional logic to define how
      # the corresponding data is persisted.
      def self.primative_acccess_right_codes
        acccess_right_codes.keys
      end
    end
  end
end
