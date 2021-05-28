require 'sipity/forms/processing_form'
require 'active_model/validations'

module Sipity
  module Forms
    module SubmissionWindows
      module Etd
        # Responsible for creating a new work within the ETD work area.
        # What goes into this is more complicated that the entity might allow.
        class StartASubmissionForm
          ProcessingForm.configure(
            form_class: self, base_class: Models::Work, processing_subject_name: :submission_window,
            policy_enforcer: Policies::SubmissionWindowPolicy,
            attribute_names: [:title, :work_publication_strategy, :work_patent_strategy, :work_type, :access_rights_answer]
          )

          def initialize(submission_window:, requested_by:, attributes: {}, **keywords)
            self.requested_by = requested_by
            self.processing_action_form = processing_action_form_builder.new(form: self, **keywords)
            self.publication_and_patenting_intent_extension = publication_and_patenting_intent_extension_builder.new(
              form: self, repository: repository
            )
            initialize_work_area_and_submission_window!(submission_window: submission_window)
            initialize_attributes(attributes)
          end

          delegate(
            :work_publication_strategy, :work_publication_strategy=, :work_publication_strategies_for_select,
            :possible_work_publication_strategies, :persist_work_publication_strategy,
            to: :publication_and_patenting_intent_extension
          )

          private(:possible_work_publication_strategies, :persist_work_publication_strategy)

          private

          attr_reader :work_area
          attr_accessor :publication_and_patenting_intent_extension

          def publication_and_patenting_intent_extension_builder
            Forms::ComposableElements::PublishingAndPatentingIntentExtension
          end

          def initialize_attributes(attributes = {})
            self.title = attributes[:title]
            self.work_publication_strategy = attributes[:work_publication_strategy]
            self.work_type = attributes[:work_type]
            self.access_rights_answer = attributes.fetch(:access_rights_answer) { default_access_rights_answer }
          end

          public

          attr_reader :work
          alias to_work_area work_area
          public :to_work_area

          delegate :slug, :work_area_slug, to: :submission_window

          include ActiveModel::Validations
          validates :title, presence: true
          validates :work_publication_strategy, presence: true, inclusion: { in: :possible_work_publication_strategies }
          validates :work_type, presence: true, inclusion: { in: :possible_work_types }
          validates :access_rights_answer, presence: true, inclusion: { in: :possible_access_right_codes }
          validates :submission_window, presence: true, open_for_starting_submissions: true
          validates :requested_by, presence: true

          def form_path
            File.join(PowerConverter.convert(submission_window, to: :processing_action_root_path), processing_action_name)
          end

          def access_rights_answer_for_select
            possible_access_right_codes.map(&:to_sym)
          end

          # Convert string to to_sym since simple_forn require sym to
          # look_up 18n translation for work_type
          def work_types_for_select
            possible_work_types.map(&:to_sym)
          end

          def submit
            return false unless valid?
            save
          end

          private

          def save
            create_the_work do |work|
              # I believe this form has too much knowledge of what is going on;
              # Consider pushing some of the behavior down into the repository.
              repository.handle_transient_access_rights_answer(entity: work, answer: access_rights_answer)
              persist_work_publication_strategy
              repository.grant_creating_user_permission_for!(entity: work, user: requested_by)
              repository.update_work_attribute_values!(work: work, key: 'author_name', values: requested_by.to_s)
              repository.update_work_attribute_values!(work: work, key: 'identifier_doi', values: default_identifier_doi)
              register_actions
            end
          end

          def register_actions
            # TODO: See Ulra::StartASubmissionForm for common behavior
            #
            # Your read that right, register actions on both the work and submission window.
            # This form crosses a conceptual boundary. I need permission within
            # the submission window to create a work. However, I want to
            # notify the creating user of the work of the action they've taken.
            repository.register_action_taken_on_entity(entity: work, action: processing_action_name, requested_by: requested_by)
            repository.register_action_taken_on_entity(
              entity: submission_window, action: processing_action_name, requested_by: requested_by
            )
            repository.register_action_taken_on_entity(entity: work, action: 'author', requested_by: requested_by)
          end

          def create_the_work
            @work = repository.create_work!(submission_window: submission_window, title: title, work_type: work_type)
            yield(@work)
            @work
          end

          def possible_work_types
            DataGenerators::WorkTypes::EtdGenerator::WORK_TYPE_NAMES
          end

          def possible_access_right_codes
            Models::AccessRight.valid_access_right_codes
          end

          def default_access_rights_answer
            Models::AccessRight::OPEN_ACCESS
          end

          def default_repository
            CommandRepository.new
          end

          def default_identifier_doi
            "To be assigned"
          end

          def initialize_work_area_and_submission_window!(submission_window:)
            @work_area = repository.find_work_area_by(slug: 'etd')
            self.submission_window = submission_window
          end

          def submission_window=(input)
            @submission_window = PowerConverter.convert(input, to: :submission_window, scope: work_area)
          end
        end
      end
    end
  end
end
