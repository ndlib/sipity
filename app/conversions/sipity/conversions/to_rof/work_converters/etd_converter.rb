require 'sipity/conversions/to_rof/work_converters/abstract_converter'
module Sipity
  module Conversions
    module ToRof
      module WorkConverters
        # Responsible for exposing the custom metadata mapping that occurs for an ETD
        class EtdConverter < AbstractConverter
          def edit_groups
            [Figaro.env.curate_grad_school_editing_group_pid!]
          end

          def af_model
            'Etd'
          end

          # @todo dc:date for defense date looks very suspect
          def metadata
            {
              "@context" => jsonld_context,
              'dc:title' => work.title,
              'dc:creator' => fetch_attribute_values(key: 'author_name'),
              'dc:title#alternate' => fetch_attribute_values(key: 'alternate_title'),
              'dc:subject' => fetch_attribute_values(key: 'subject'),
              'dc:description#abstract' => fetch_attribute_values(key: 'abstract'),
              'dc:rights' => fetch_attribute_values(key: 'copyright'),
              'dc:language' => fetch_attribute_values(key: 'language'),
              'dc:date' => fetch_attribute_values(key: 'defense_date'),
              'dc:dateSubmitted' => format_date(Time.zone.today),
              'dc:contributor' => collaborator_metadata,
              'ms:degree' => degree_metadata
            }
          end

          def rels_ext
            {
              "@context" => jsonld_context,
              'hydramata-rel:hasEditor' => [Figaro.env.curate_batch_user_pid!],
              'hydramata-rel:hasEditorGroup' => edit_groups
            }
          end

          def attachments
            Array.wrap(repository.work_attachments(work: work, predicate_name: :all))
          end

          private

          def degree_metadata
            {
              'ms:name' => fetch_attribute_values(key: 'degree'),
              'ms:discipline' => fetch_attribute_values(key: 'program_name'),
              'ms:level' => etd_degree_level_from_work_type
            }
          end

          # @todo I cannot imagine that we really want dc:contributor to be nested within a dc:contributor data structure
          def collaborator_metadata
            Array.wrap(repository.work_collaborators_for(work: work)).map do |collaborator|
              { 'dc:contributor' => collaborator.name, 'ms:role' => collaborator.role }
            end
          end

          def etd_degree_level_from_work_type
            # I could be using the translations, but under test this falls apart as I don't load the translations.
            # Loading translations adds a significant chunk of time to the test suite.
            {
              Models::WorkType::DOCTORAL_DISSERTATION => "Doctoral Dissertation",
              Models::WorkType::MASTER_THESIS => "Master’s Thesis"
            }.fetch(work.work_type)
          end
        end
      end
    end
  end
end
