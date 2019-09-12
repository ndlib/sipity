require 'site_prism'
module SitePrism
  module Pages
    module WithNamedObjectBehavior
      def take_named_action(name)
        take_action_on(find_named_object(name))
      end

      def take_action_on(entry_point)
        # I'm thinking how can I click on either a submit button or an a-tag.
        #
        # Since names are helpful, but machines like URLs better, I opted to
        # first find the URL, and fallback to the named action for something to
        # click on.
        action = begin
          entry_point.find("[itemprop='target'] [itemprop='url']")
        rescue Capybara::ElementNotFound
          entry_point.find("[itemprop='target'] [itemprop='name']")
        end
        action.click
      end

      def find_named_object(name, itemprop: 'potentialAction')
        object_name_node = find("[itemprop='#{itemprop}'] [itemprop='name'][content='#{name.downcase}']")
        # Because Capybara does not support an ancestors/parents find method (at
        # least as expected), I need to dive into the native object.
        case object_name_node.native
        when Nokogiri::XML::Element
          find_named_object_for_nokogiri(object_name_node.native)
        when Capybara::Poltergeist::Node
          find_named_object_for_poltergeist(object_name_node.native)
        else
          raise "Unexpected #native value for #{object_name_node}"
        end
      end

      private

      def find_named_object_for_nokogiri(nokogiri_node)
        # Because Capybara does not support an ancestors find method, I need
        # to dive into the native object (i.e. a Nokogiri node). The end goal
        # is to find the named object element and thus be able to retrieve any
        # of the underlying attributes.
        parent_ng_node = nokogiri_node.ancestors('[itemscope]').first
        find(parent_ng_node.css_path)
      end

      def find_named_object_for_poltergeist(poltergeist_node)
        # This is a Poltergeist node. The end goal is to find the named object
        # element and thus be able to retrieve any of the underlying
        # attributes.
        parent_native_node = poltergeist_node.parents.find('[itemscope]').first
        # Smooshing this back into a Capybara::Node, because we have a
        # Poltergeist node.
        Capybara::Node::Element.new(
          object_name_node.session,
          parent_native_node,
          parent_native_node.parents.first,
          self
        )
      end
    end

    class NewWorkPage < SitePrism::Page
      PARAM_NAME_CONTAINER = 'submission_window'.freeze

      element :form, "form"
      element :input_title, "form [name='#{PARAM_NAME_CONTAINER}[title]']"
      element :submit_button, "form [type='submit']"

      def fill_in(predicate, with: nil)
        find("form [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end

      def choose(predicate, with: nil)
        all("form [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").each do |input|
          if input.value == with
            input.set(true)
            break
          end
        end
      end

      def select(value, from: nil)
        find("form select[name='#{PARAM_NAME_CONTAINER}[#{from}]'] option[value='#{value}']").select_option
      end
    end

    class EditWorkPage < SitePrism::Page
      PARAM_NAME_CONTAINER = 'work'.freeze

      element :form, "form"
      element :input_title, "form [name='#{PARAM_NAME_CONTAINER}[title]']"
      element :submit_button, "form [type='submit']"

      def fill_in(predicate, with: nil)
        find("form [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end

      def choose(predicate, with: nil)
        all("form [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").each do |input|
          if input.value == with
            input.set(true)
            break
          end
        end
      end

      def select(value, from: nil)
        find("form select[name='#{PARAM_NAME_CONTAINER}[#{from}]'] option[value='#{value}']").select_option
      end
    end

    class WorkPage < SitePrism::Page
      include WithNamedObjectBehavior

      def text_for(predicate)
        all(" .value.#{predicate}").map(&:text)
      end

      def click_recommendation(recommendation)
        take_action_on(find_named_object("enrichment/optional/#{recommendation.downcase}"))
      end

      def click_edit
        take_action_on(find_named_object('event_trigger/edit'))
      end

      def click_todo_item(name)
        take_action_on(find_named_object(name))
      end

      def todo_item_named_status_for(name)
        find_named_object(name).find("[itemprop='actionStatus']").text
      end

      def processing_state
        find_named_object('work/processing_state', itemprop: 'hasPart').find("[itemprop='description']").text
      end
    end

    class EventTriggerPage < SitePrism::Page
      include WithNamedObjectBehavior
    end

    class DescribePage < SitePrism::Page
      PARAM_NAME_CONTAINER = 'work'.freeze
      element :input_abstract, "form [name='#{PARAM_NAME_CONTAINER}[abstract]']"
      element :submit_button, "form [name='form/describe/submit'][type='submit']"

      def fill_in(predicate, with: nil)
        find("form [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end
    end

    class CollaboratorsPage < SitePrism::Page
      PARAM_NAME_CONTAINER = 'work'.freeze
      element :submit_button, "form [name='form/collaborators/submit'][type='submit']"
    end

    class AttachPage < SitePrism::Page
      PARAM_NAME_CONTAINER = 'work'.freeze
      element :form, "form[method='post']"
      element :input_file, "form [name='#{PARAM_NAME_CONTAINER}[files][]'][multiple='multiple']"
      element :submit_button, "form [name='form/attach/submit'][type='submit']"

      def attach_file(path, options = {})
        super("#{PARAM_NAME_CONTAINER}[files][]", path, options)
      end
    end

    class AssignDoiPage < SitePrism::Page
      DOM_CLASS = 'assign_a_doi'.freeze
      PARAM_NAME_CONTAINER = 'doi'.freeze
      element :form, "form.#{DOM_CLASS}"
      element :input_identifier, "form.#{DOM_CLASS} [name='#{PARAM_NAME_CONTAINER}[identifier]']"
      element :submit_button, "form.#{DOM_CLASS} [type='submit']"

      def fill_in(predicate, with: nil)
        find("form.#{DOM_CLASS} [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end
    end

    class NewCitationPage < SitePrism::Page
      PARAM_NAME_CONTAINER = 'citation'.freeze
      element :form, "form"
      element :input_citation, "form textarea[name='#{PARAM_NAME_CONTAINER}[citation]']"
      element :input_type, "form [name='#{PARAM_NAME_CONTAINER}[type]']"
      element :submit_button, "form [type='submit']"

      def fill_in(predicate, with: nil)
        find("form [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end
    end

    class AccountPage < SitePrism::Page
      PARAM_NAME_CONTAINER = 'account'.freeze
      element :preferred_name, "form [name='#{PARAM_NAME_CONTAINER}[preferred_name]']"
      element :agree_to_tos, "form [type='checkbox'][name='#{PARAM_NAME_CONTAINER}[agreed_to_terms_of_service]']"
      element :submit_button, "form [type='submit']"
    end
  end

  module OnThisPage
    def on(page_name)
      SitePrism::Pages.const_get(page_name.to_s.classify).new.tap { |p| yield(p) }
    end
  end
end

RSpec.configure do |config|
  config.include(SitePrism::OnThisPage, type: :feature)
end
