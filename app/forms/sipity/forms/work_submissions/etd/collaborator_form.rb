# frozen_string_literal: true

require 'sipity/forms/processing_form'
require 'active_model/validations'
require 'active_support/core_ext/array/wrap'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        # Exposes a means for attaching files to the associated work.
        class CollaboratorForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :work,
            attribute_names: [:collaborators_attributes]
          )

          def initialize(work:, requested_by:, attributes: {}, **keywords)
            self.work = work
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.collaborators_attributes = attributes[:collaborators_attributes]
          end

          attr_reader :collaborators_from_input

          include ActiveModel::Validations
          validate :each_collaborator_from_input_must_be_valid
          validate :at_least_one_collaborator_must_be_research_director_with_netid
          validates :work, presence: true
          validates :requested_by, presence: true

          # When the form is being rendered, the fields_for :collaborators drive
          # on this method, as such this is a read only method.
          def collaborators
            (collaborators_from_input || collaborators_from_work) + an_empty_collaborator_for_form_rendering
          end

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

          def submit
            processing_action_form.submit do
              # Don't try to persist the collaborators, as those are for form rendering
              # instead lets persist the collaborators that were given as user input.
              repository.manage_collaborators_for(work: work, collaborators: collaborators_from_input)
            end
          end

          def possible_roles
            Models::Collaborator.roles.slice(Models::Collaborator::RESEARCH_DIRECTOR_ROLE,
                                             Models::Collaborator::COMMITTEE_MEMBER_ROLE)
          end

          private

          def collaborators_from_work
            return [] unless work
            # Manually building an empty collaborator to allow adding more once
            # one is already created:
            work.collaborators
          end

          def build_collaborator_from_input(collection, attributes)
            return if reject_because_an_empty_row_was_submitted_via_user_input?(attributes)
            collaborator = repository.find_or_initialize_collaborators_by(work: work, id: attributes[:id])
            collaborator.attributes = extract_collaborator_attributes(attributes)
            collaborator.responsible_for_review = determine_if_role_is_responsible_for_review(attributes[:role])
            collection << collaborator
          end

          def reject_because_an_empty_row_was_submitted_via_user_input?(attributes)
            attributes.except(:responsible_for_review, :role).values.none?(&:present?)
          end

          def extract_collaborator_attributes(attributes)
            permitted_attributes = attributes.slice(:name, :role, :netid, :email).reject { |_key, value| value.empty? }
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

          def at_least_one_collaborator_must_be_research_director_with_netid
            return true unless Array.wrap(collaborators_from_input).none? do |collaborator|
              determine_if_role_is_responsible_for_review_with_netid(collaborator)
            end
            errors.add(:base, :at_least_one_collaborator_must_be_research_director_with_netid)
          end

          def determine_if_role_is_responsible_for_review(role)
            return true if role == Models::Collaborator::RESEARCH_DIRECTOR_ROLE
            false
          end

          def determine_if_role_is_responsible_for_review_with_netid(collaborator)
            return true if collaborator.role == Models::Collaborator::RESEARCH_DIRECTOR_ROLE && collaborator.netid.present?
            false
          end
        end
      end
    end
  end
end
