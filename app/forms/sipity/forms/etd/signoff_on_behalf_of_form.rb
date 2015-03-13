module Sipity
  module Forms
    module Etd
      # Responsible for exposing ability for someone to signoff on the work
      # on behalf of someone else.
      class SignoffOnBehalfOfForm < Forms::StateAdvancingAction
        def initialize(attributes = {})
          super
          @on_behalf_of_collaborator_id = attributes[:on_behalf_of_collaborator_id]
          @signoff_service = attributes.fetch(:signoff_service) { default_signoff_service }
        end
        attr_reader :on_behalf_of_collaborator_id
        attr_reader :signoff_service
        private :signoff_service

        validates :on_behalf_of_collaborator_id, presence: true, inclusion: { in: :valid_on_behalf_of_collaborator_ids }

        def valid_on_behalf_of_collaborators
          repository.collaborators_that_can_advance_the_current_state_of(work: work)
        end

        def render(f:)
          f.input(:on_behalf_of_collaborator_id, collection: valid_on_behalf_of_collaborators, value_method: :id)
        end

        def on_behalf_of_collaborator
          repository.collaborators_that_can_advance_the_current_state_of(work: work, id: on_behalf_of_collaborator_id).first
        end

        private

        def valid_on_behalf_of_collaborator_ids
          valid_on_behalf_of_collaborators.map { |collaborator| collaborator.id.to_s }
        end

        def save(requested_by:)
          register_the_actions(requested_by: requested_by)
          repository.log_event!(entity: work, user: requested_by, event_name: event_name)
          signoff_service.call(form: self, requested_by: requested_by, repository: repository)
          work
        end

        RELATED_ACTION_FOR_SIGNOFF = 'advisor_signoff'
        def register_the_actions(requested_by:)
          repository.register_action_taken_on_entity(
            work: work, enrichment_type: enrichment_type, requested_by: requested_by, on_behalf_of: on_behalf_of_collaborator
          )
          @registered_action = repository.register_action_taken_on_entity(
            work: work, enrichment_type: RELATED_ACTION_FOR_SIGNOFF, requested_by: requested_by, on_behalf_of: on_behalf_of_collaborator
          )
        end

        def default_signoff_service
          Services::AdvisorSignsOff
        end
      end
    end
  end
end
