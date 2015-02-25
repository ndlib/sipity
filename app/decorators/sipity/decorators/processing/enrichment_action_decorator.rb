require_relative './base_decorator'
module Sipity
  module Decorators
    module Processing
      # A decorator for the EnrichmentAction; Either required or optional.
      class EnrichmentActionDecorator < BaseDecorator
        def initialize(options = {})
          super
          @is_complete = options.fetch(:is_complete) { false }
          @is_a_prerequisite = options.fetch(:is_a_prerequisite) { false }
        end

        attr_reader :is_complete, :is_a_prerequisite

        alias_method :is_complete?, :is_complete
        alias_method :is_a_prerequisite?, :is_a_prerequisite

        def state
          is_complete? ? 'done' : 'incomplete'
        end

        def label
          i18n_options = { scope: "sipity/decorators/entitiy_enrichment_actions.#{name}" }

          if entity.respond_to?(:work_type)
            i18n_options[:entity_type] = I18n.t("simple_form.options.defaults.work_type.#{entity.work_type}").downcase
          else
            i18n_options[:entity_type] = 'item'
          end

          I18n.t(:label, i18n_options).html_safe
        end

        def path
          view_context.enrich_work_path(entity, name)
        end

        def button_class
          return 'btn-default' if is_complete?
          return 'btn-primary' if is_a_prerequisite?
          'btn-info'
        end

        private

        def view_context
          Draper::ViewContext.current
        end
      end
    end
  end
end
