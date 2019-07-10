module Sipity
  module Controllers
    # Responsible for rendering a resourceful action in the context of a
    # WorkArea.
    class ResourcefulActionPresenter < Curly::Presenter
      presents :resourceful_action

      attr_reader :resourceful_action
      private :resourceful_action

      delegate :name, to: :@resourceful_action, prefix: :action

      def render_entry_point
        content_tag('div', itemprop: 'target', itemscope: true, itemtype: "http://schema.org/EntryPoint", class: "action") do
          if available?
            render_available_inner_html_entry_point
          else
            render_unavailable_inner_html_for_entry_point
          end
        end
      end

      def path
        raise NotImplementedError
      end

      def availability_state
        STATE_AVAILABLE
      end

      private

      DESTROY_ACTION_NAME = 'destroy'.freeze
      STATE_AVAILABLE = 'available'.freeze

      def available?
        availability_state == STATE_AVAILABLE
      end

      def render_available_inner_html_entry_point
        link_to(entry_point_text, path, entry_point_attributes)
      end

      def render_unavailable_inner_html_for_entry_point
        (
          content_tag('meta', '', itemprop: 'name', content: action_name) +
          content_tag('span', class: 'btn btn-default disabled') do
            I18n.t("sipity/works.resourceful_actions.label.#{action_name}")
          end
        ).html_safe
      end

      def entry_point_attributes
        { itemprop: 'url', class: "btn #{button_class}" }
      end

      def entry_point_text
        text = I18n.t("sipity/decorators/resourceful_actions.label.#{action_name}")
        text += %(<meta itemprop="name" content="#{action_name}" />)
        text.html_safe
      end

      def button_class
        dangerous? ? 'btn-danger' : 'btn-primary'
      end

      def dangerous?
        action_name.to_s == DESTROY_ACTION_NAME
      end
    end
  end
end
