module Sipity
  module Forms
    module WorkEnrichments
      # Exposes a means for attaching files to the associated work.
      class CollaboratorForm < Forms::WorkEnrichmentForm
        def initialize(attributes = {})
          super
          self.collaborators_attributes = attributes[:collaborators_attributes]
        end
        attr_reader :collaborators_attributes, :collaborators_from_input
        private :collaborators_from_input

        # When the form is being rendered, the fields_for :collaborators drive
        # on this method, as such this is a read only method.
        def collaborators
          (collaborators_from_input || collaborators_from_work) + an_empty_collaborator_for_form_rendering
        end

        validate :each_collaborator_from_input_must_be_valid
        validate :at_least_one_collaborator_must_be_responsible_for_review

        # Mirroring the expected behavior/implementation of the
        # :accepts_nested_attributes_for Rails method and its sibling :fields_for
        #
        # When the form is submitted, this is what will be written.
        #
        # Keep in mind, when the form is rendered, we will be driving from the
        # #collaborators method. So if that has 2 collaborators, the form will
        # render with those two collaborators and be submitted with that
        # information.
        #
        # @note Don't privatize me bro! I'm a good public servant. If
        #   #collaborators_attributes= is not a public method then the expected
        #   interface for :accepts_nested_attributes_for and :fields_for breaks
        #   down.
        def collaborators_attributes=(inputs)
          return inputs unless inputs.present?
          @collaborators_from_input = []
          inputs.each do |_, attributes|
            build_collaborator_from_input(@collaborators_from_input, attributes)
          end
          @collaborators_attributes = inputs
        end

        private

        def save(requested_by:)
          super { repository.manage_collaborators_for(work: work, collaborators: collaborators) }
        end

        def collaborators_from_work
          return [] unless work
          # Manually building an empty collaborator to allow adding more once
          # one is already created:
          work.collaborators
        end

        def build_collaborator_from_input(collection, attributes)
          return if blank_inputs_were_given_for?(attributes)
          collaborator = repository.find_or_initialize_collaborators_by(work: work, id: attributes[:id])
          collaborator.attributes = extract_collaborator_attributes(attributes)
          collection << collaborator
        end

        def blank_inputs_were_given_for?(attributes)
          attributes.except(:responsible_for_review).none?(&:present?)
        end

        def extract_collaborator_attributes(attributes)
          permitted_attributes = attributes.slice(:name, :role, :netid, :email, :responsible_for_review)
          # Because Rails strong parameters may or may not be in play.
          permitted_attributes.permit! if permitted_attributes.respond_to?(:permit!)
          permitted_attributes
        end

        def an_empty_collaborator_for_form_rendering
          [Models::Collaborator.build_default]
        end

        def each_collaborator_from_input_must_be_valid
          return true if Array.wrap(collaborators_from_input).all?(&:valid?)
          errors.add(:collaborators_attributes, :are_incomplete)
        end

        def at_least_one_collaborator_must_be_responsible_for_review
          return true unless Array.wrap(collaborators_from_input).none?(&:responsible_for_review?)
          errors.add(:base, :at_least_one_collaborator_must_be_responsible_for_review)
        end
      end
    end
  end
end
