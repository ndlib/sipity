module Sipity
  module Forms
    # Responsible for capturing and validating the assignment of a DOI that
    # already exists but has not yet been assigned to the SIP
    class AssignADoiForm < BaseForm
      self.policy_enforcer = Policies::EnrichSipByFormSubmissionPolicy

      def initialize(attributes = {})
        self.sip = attributes.fetch(:sip)
        self.identifier = attributes.fetch(:identifier, nil)
      end

      attr_accessor :sip, :identifier
      private(:sip=) # Adding parenthesis because Beautify ruby was going crazy

      validates :sip, presence: true
      validates :identifier, presence: true

      # TODO: Get this out of here. There is an object that is a better owner of
      # this method. But for now it is here based on a view implementation.
      def assign_a_doi_form
        self
      end

      def identifier_key
        Models::AdditionalAttribute::DOI_PREDICATE_NAME
      end

      # TODO: Get this out of here. There is an object that is a better owner of
      # this method. But for now it is here based on a view implementation.
      def request_a_doi_form
        RequestADoiForm.new(sip: sip)
      end
    end
  end
end
