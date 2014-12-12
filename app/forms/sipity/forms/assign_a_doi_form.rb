module Sipity
  module Forms
    # Responsible for capturing and validating the assignment of a DOI that
    # already exists but has not yet been assigned to the SIP
    class AssignADoiForm < VirtualForm
      self.policy_enforcer = Policies::EnrichHeaderByFormSubmissionPolicy

      def initialize(attributes = {})
        self.header = attributes.fetch(:header)
        self.identifier = attributes.fetch(:identifier, nil)
      end

      attr_accessor :header, :identifier
      private(:header=) # Adding parenthesis because Beautify ruby was going crazy

      validates :header, presence: true
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
        RequestADoiForm.new(header: header)
      end
    end
  end
end
