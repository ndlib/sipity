require 'sipity/conversions/convert_to_permanent_uri'

module Sipity
  module Controllers
    module WorkSubmissions
      # Responsible for "showing" a WorkSubmission
      #
      # In the case of the render method, I want to leverage the view path for
      # the presenter, instead of relying on Rail's magical partial lookup logic.
      #
      # In otherwords, without the leading '/' on the `render partial:` the
      # rendering will look for a partial in the current directory of what has
      # been rendered (more or less). With the leading `/`, render will use
      # the rendering contexts (i.e. Controller's) view_paths to find the
      # template file in those view_path directories.
      class ShowPresenter < Curly::Presenter
        presents :work_submission

        def initialize(context, options = {})
          # Because controller actions may not cooperate and instead set a
          # :view_object.
          options.stringify_keys!
          options['work_submission'] ||= options['view_object']
          self.repository = options.fetch('repository') { default_repository }
          super
          self.processing_actions = compose_processing_actions
        end

        def render_enrichment_action_set(identifier)
          object = action_set_for(name: 'enrichment_actions', identifier: identifier)
          render partial: "/enrichment_action_set", object: object if object.present?
        end

        # NOTICE THE DUPLICATION ABOVE AND BELOW
        def render_state_advancing_action_set
          object = action_set_for(name: 'state_advancing_actions')
          render partial: "/state_advancing_action_set", object: object
        end

        def render_processing_state_notice
          render partial: "/processing_state_notice", object: self
        end

        def render_current_comments
          # I'm keeping these as one method as its all rather interrelated
          # Plus, I'd prefer to not memoize comments
          current_comments = repository.find_current_comments_for(entity: work_submission)
          return unless current_comments.any?
          object = Parameters::EntityWithCommentsParameter.new(comments: current_comments, entity: work_submission)
          render partial: "/current_comments", object: object
        end

        def render_additional_attribute_set
          object = Parameters::EntityWithAdditionalAttributesParameter.new(
            entity: work_submission, additional_attributes: work_submission.additional_attributes
          )
          render partial: '/additional_attribute_set', object: object
        end

        def render_accessible_object_set
          render partial: '/accessible_object_set', object: work_submission
        end

        delegate(
          :resourceful_actions, :resourceful_actions?,
          :enrichment_actions, :enrichment_actions?,
          :state_advancing_actions, :state_advancing_actions?,
          :action_set_for, :can_advance_processing_state?,
          to: :processing_actions
        )

        # TODO: work_type, processing_state should be translated
        delegate :id, to: :work_submission, prefix: :work
        delegate :collaborators, :title, to: :work_submission

        def collaborators?
          collaborators.present?
        end

        def creators?
          creators.present?
        end

        def creators
          @creators ||= repository.scope_users_for_entity_and_roles(entity: work_submission, roles: Sipity::Models::Role::CREATING_USER)
        end

        def work_type
          TranslationAssistant.call(scope: :work_types, subject: work_submission.work_type)
        end

        def processing_state
          work_submission.processing_state.to_s
        end

        def human_readable_processing_state
          TranslationAssistant.call(scope: :processing_states, subject: work_submission, object: processing_state)
        end

        def label(identifier)
          # TODO: Is there a better way to namespace this?
          Models::Work.human_attribute_name(identifier)
        end

        def section(identifier)
          TranslationAssistant.call(scope: :sections, subject: work_submission, object: identifier)
        end

        def repository_url_label
          TranslationAssistant.call(scope: :sections, subject: work_submission, object: 'repository_url')
        end

        include Conversions::ConvertToPermanentUri
        def repository_url_for_work
          convert_to_permanent_uri(work_submission)
        end

        private

        attr_reader :work_submission

        attr_accessor :processing_actions

        def compose_processing_actions
          ComposableElements::ProcessingActionsComposer.new(user: current_user, entity: work_submission)
        end

        attr_accessor :repository

        def default_repository
          QueryRepository.new
        end
      end
    end
  end
end
