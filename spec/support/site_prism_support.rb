require 'site_prism'
module SitePrism
  module Pages
    class NewWorkPage < SitePrism::Page
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
      def text_for(predicate)
        all(" .value.#{predicate}").map(&:text)
      end

      def click_recommendation(recommendation)
        find(".recommendation .value .recommendation-#{recommendation.downcase}").click
      end

      def click_todo_item(name)
        find_named_object(name).find("[itemprop='url']").click
      end

      def click_edit
        find('.action-edit').click
      end

      def todo_item_named_status_for(name)
        find_named_object(name).find("[itemprop='actionStatus']").text
      end

      private

      def find_named_object(name)
        object_name_node = find("[itemprop='name'][content='#{name.downcase}']")
        # Because Capybara does not support an ancestors find method, I need to
        # dive into the native object (i.e. a Nokogiri node). The end goal is to
        # find the named object element and thus be able to retrieve any of the
        # underlying attributes.
        parent_ng_node = object_name_node.native.ancestors('[itemscope]').first
        find(parent_ng_node.path)
      end
    end

    class DescribePage < SitePrism::Page
      PARAM_NAME_CONTAINER = 'work'.freeze
      element :input_abstract, "form [name='#{PARAM_NAME_CONTAINER}[abstract]']"
      element :submit_button, "form [name='form>describe>submit'][type='submit']"

      def fill_in(predicate, with: nil)
        find("form [name='#{PARAM_NAME_CONTAINER}[#{predicate}]']").set(with)
      end
    end

    class AttachPage < SitePrism::Page
      PARAM_NAME_CONTAINER = 'work'.freeze
      element :form, "form[method='post']"
      element :input_file, "form [name='#{PARAM_NAME_CONTAINER}[files][]'][multiple='multiple']"
      def attach_file(path, options = {})
        # NOTE: I believe this will work, however I am not certain
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
