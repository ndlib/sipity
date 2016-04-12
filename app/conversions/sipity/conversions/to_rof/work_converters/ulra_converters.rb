require 'sipity/conversions/to_rof/work_converters/abstract_converter'
module Sipity
  module Conversions
    module ToRof
      module WorkConverters
        # Below are the available attributes for a given ULRA Submission. These are valid up to and including the date of the commit.
        #
        # attached_files_completion_state
        # award_category
        # copyright
        # course_name
        # course_number
        # expected_graduation_term
        # is_an_award_winner
        # majors
        # minors
        # other_resources_consulted
        # primary_college
        # project_url
        # publication_name
        # publication_status_of_submission
        # resources_consulted
        # submitted_for_publication
        # underclass_level
        class UlraSeniorThesisConverter < AbstractConverter
          # @todo Do we need to create an ULRA group?
          def edit_groups
            []
          end

          def af_model
            'SeniorThesis'
          end

          def to_hash
            super.merge('collections' => collections)
          end

          def metadata
            {
              '@context' => jsonld_context,
              'dc:title' => work.title,
              'dc:creator' => creator_names,
              'dc:contributor#advisor' => advising_faculty,
              'dc:description' => fetch_attribute_values(key: 'abstract'),
              'dc:rights' => fetch_attribute_values(key: 'copyright'),
              'dc:created' => format_date(work.created_at),
              'dc:modified' => format_date(Time.zone.today),
              'dc:dateSubmitted' => format_date(Time.zone.today)
            }
          end

          def rels_ext
            {
              "@context" => jsonld_context,
              'hydramata-rel:hasEditor' => [Figaro.env.curate_batch_user_pid!],
              'hydramata-rel:hasEditorGroup' => edit_groups
            }
          end

          def advising_faculty
            Array.wrap(repository.work_collaborator_names_for(work: work, role: Models::Collaborator::ADVISING_FACULTY_ROLE))
          end

          def creator_names
            Array.wrap(
              repository.scope_users_for_entity_and_roles(entity: work, roles: Models::Role::CREATING_USER)
            ).map(&:name)
          end

          ATTACHMENT_TYPES_FOR_EXPORT = %w(project_file submission_essay).freeze
          def attachments
            Array.wrap(repository.work_attachments(work: work, predicate_name: ATTACHMENT_TYPES_FOR_EXPORT))
          end

          def collections
            collections = [collection_pid_for('participant')]
            collections += [collection_pid_for('award_recipient')] if an_award_winner?
            collections
          end

          private

          def an_award_winner?
            PowerConverter.convert(fetch_attribute_values(key: 'is_an_award_winner', cardinality: 1), to: :boolean)
          end

          def collection_pid_for(key)
            repository.collection_pid_for(submission_window: work, key: key)
          end
        end

        # Map the ULRA Submission to a Document
        class UlraDocumentConverter < UlraSeniorThesisConverter
          def af_model
            'Document'
          end

          def metadata
            super.merge('dc:type' => 'Document')
          end
        end
      end
    end
  end
end
