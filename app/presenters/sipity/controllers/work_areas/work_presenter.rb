module Sipity
  module Controllers
    module WorkAreas
      # Responsible for rendering a given work within the context of the Dashboard.
      #
      # @note This could be extracted outside of this namespace
      class WorkPresenter < Curly::Presenter
        presents :work

        def path
          PowerConverter.convert(work, to: :access_path)
        end

        def work_type
          work.work_type.to_s.humanize
        end

        def author_name
          if work.respond_to?(:author_name)
            # This condition is when the underlying ActiveRecord query
            # adds the pseudo-attribute author name
            work.author_name
          else
            # And the fallback if something upstream has not done that.
            additional_attribute_for(key: "author_name", cardinality: 1)
          end
        end

        def creator_names_to_sentence
          creators.to_sentence
        end

        def creator_names_as_email_links
          creators.map do |creator|
            mail_to(creator.email, creator, subject: "Your #{submission_window.slug} ULRA submission")
          end.join(' ').html_safe
        end

        def advisor_names_as_email_links
          advisors.map do |advisor|
            mail_to(advisor.email, advisor, subject: "#{submission_window.slug} ULRA submission for #{creator_names_to_sentence}")
          end.join(' ').html_safe
        end

        def submission_window
          work.submission_window
        end

        def program_names_to_sentence
          if work.respond_to?(:program_name)
            # This condition is when the underlying ActiveRecord query
            # adds the pseudo-attribute program_name.
            work.program_name
          else
            Array.wrap(additional_attribute_for(key: "program_name", cardinality: :many)).to_sentence
          end
        end

        def date_created
          work.created_at.strftime('%a, %d %b %Y')
        end

        def etd_submission_date
          if work.respond_to?(:etd_submission_date)
            # This condition is when the underlying ActiveRecord query
            # adds the pseudo-attribute submission date
            work.etd_submission_date
          else
            # And the fallback if something upstream has not done that.
            additional_attribute_for(key: "etd_submission_date", cardinality: 1)
          end
        end

        def processing_state
          work.processing_state.to_s.humanize
        end

        def title
          work.title.to_s.html_safe
        end

        private

        attr_reader :work
        def creators
          # The repository comes from the underlying context; Which is likely a controller.
          @creators ||= Array.wrap(repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER))
        end

        def advisors
          # The repository comes from the underlying context; Which is likely a controller.
          @advisors ||= Array.wrap(repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::ADVISING))
        end

        def additional_attribute_for(key:, cardinality:)
          repository.work_attribute_values_for(work: work, key: key, cardinality: cardinality)
        end
      end
    end
  end
end
