module Sipity
  module Decorators
    module Emails
      # Responsible for exposing methods required for email delivery. Nothing
      # too fancy.
      class WorkEmailDecorator
        def initialize(work, repository: default_repository)
          self.work = work
          self.repository = repository
        end

        def title
          work.to_s
        end

        def permanent_url
          Conversions::ConvertToPermanentUri.call(work)
        end

        def work_type
          Sipity::Controllers::TranslationAssistant.call(scope: :work_types, subject: work.work_type)
        end

        def collaborators
          @collaborators ||= repository.work_collaborators_for(work: work)
        end

        def reviewers
          @reviewers ||= repository.work_collaborators_responsible_for_review(work: work)
        end

        def additional_committe_members
          collaborators - reviewers
        end

        def creator_names
          creators.map(&:name)
        end

        def creator_netids
          creators.map(&:username)
        end

        def accessible_objects(predicate_name: :all)
          repository.access_rights_for_accessible_objects_of(work: work, predicate_name: predicate_name)
        end

        def work_access
          @work_access ||= Models::AccessRightFacade.new(work, work: work)
        end

        def accessible_files(predicate_name: :all)
          repository.work_attachments(work: work, predicate_name: predicate_name).map do |object|
            Models::AccessRightFacade.new(object, work: work)
          end
        end

        # TODO: The methods with `email_message_` prefix are ripe for extraction
        #   into a composed object. After all they are shared with the
        #   ProcessingCommentDecorator.
        # Related to building information for https://developers.google.com/gmail/markup/
        def email_message_action_url
          view_context.work_url(work)
        end

        def program_names
          repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::PROGRAM_NAME_PREDICATE_NAME)
        end

        def degree
          repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::DEGREE_PREDICATE_NAME)
        end

        def publishing_intent
          repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::WORK_PUBLICATION_STRATEGY)
        end

        def patent_intent
          repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::WORK_PATENT_STRATEGY)
        end

        def submission_date
          repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::ETD_SUBMISSION_DATE)
        end

        def catalog_system_number
          repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::CATALOG_SYSTEM_NUMBER, cardinality: 1)
        end

        def email_message_action_name
          "Review #{work_type}"
        end

        def email_message_action_description
          "Review #{work_type} “#{title}”"
        end

        def identifier_doi
          repository.work_attribute_values_for(work: work, key: Models::AdditionalAttribute::DOI_PREDICATE_NAME)
        end

        private

        attr_reader :work
        attr_accessor :repository

        include Conversions::ConvertToWork
        def work=(object)
          @work = convert_to_work(object)
        end

        def view_context
          Draper::ViewContext.current
        end

        def default_repository
          QueryRepository.new
        end

        def creators
          @creators ||= repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER)
        end
      end
    end
  end
end
