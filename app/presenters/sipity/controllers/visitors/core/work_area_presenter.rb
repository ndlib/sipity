require 'active_support/core_ext/array/wrap'

module Sipity
  module Controllers
    module Visitors
      module Core
        # Responsible for presenting a work area
        #
        # TODO: Consider this presenter as a more complicated composition of
        #   both work area and submission window; That is more reflective of
        #   the reality.
        class WorkAreaPresenter < Curly::Presenter
          presents :work_area
          def initialize(context, options = {})
            self.repository = options.delete(:repository) { default_repository }
            self.translator = options.delete(:translator) { default_translator }
            options.stringify_keys!
            # Because controller actions may not cooperate and instead set a
            # :view_object.
            options['work_area'] ||= options['view_object']
            super(context, options)
            self.processing_actions = compose_processing_actions
            initialize_submission_window_variables!
          end

          private

          attr_accessor :processing_actions
          attr_reader :work_area

          public

          delegate :name, to: :work_area

          def to_work_area
            work_area
          end

          delegate(
            :resourceful_actions, :resourceful_actions?,
            :enrichment_actions, :enrichment_actions?,
            :state_advancing_actions, :state_advancing_actions?,
            to: :processing_actions
          )

          private

          attr_accessor :translator

          private def default_translator
            Controllers::TranslationAssistant
          end

          private def default_translation_scope
            "processing_actions.show"
          end

          public def translate(identifier, scope: default_translation_scope, predicate: :label)
            translator.call(scope: scope, subject: work_area, object: identifier, predicate: predicate)
          end

          private def compose_processing_actions
            ComposableElements::ProcessingActionsComposer.new(repository: repository, user: current_user, entity: work_area)
          end

          public def processing_state
            work_area.processing_state.to_s
          end

          attr_accessor :repository

          private def default_repository
            QueryRepository.new
          end

          # TODO: There is a more elegant way to do this, but for now it is the
          # way things shall be done.
          ACTION_NAME_THAT_IS_HARD_CODED = 'start_a_submission'.freeze
          SUBMISSION_WINDOW_SLUG_THAT_IS_HARD_CODED = 'start'.freeze

          include Conversions::ConvertToProcessingAction
          private def initialize_submission_window_variables!
            # Critical assumption about ETD structure. This is not a long-term
            # solution, but one to get things out the door.
            self.submission_window = repository.find_submission_window_by(
              slug: SUBMISSION_WINDOW_SLUG_THAT_IS_HARD_CODED, work_area: work_area
            )
            self.start_a_submission_action = convert_to_processing_action(ACTION_NAME_THAT_IS_HARD_CODED, scope: submission_window)
          end

          attr_accessor :submission_window, :start_a_submission_action

          public def start_a_submission_path
            File.join(PowerConverter.convert(submission_window, to: :processing_action_root_path), start_a_submission_action.name)
          end
        end
      end
    end
  end
end
