module Sipity
  module Jobs
    module Core
      # Responsible for managing the processing of each and every work in the :work_area_slug that is in the :initial_processing_state_name.
      # It will use the given :processing_action_name as part of a batch action.
      #
      # As these are jobs, I believe that I want the parameters to all be primatives (i.e. a String, an Integer). This way they can
      # be serialized without holding too much state. The BulkIngestJob makes use of the [curatend-batch](https://github.com/ndlib/curatend-batch)
      # process.
      #
      # @note Run the Bulk Ingest Job from development; As with all how to documentation, your mileage may vary
      #   1. Mount the curatend-batch directory (smb://library.corpfs.nd.edu/DCNS/Library/Departmental/curatend-batch)
      #      * In OS X, go to Finder, Connect to Server... [Cmd+K] and paste the above URL
      #   2. Update the ./config/application.yml entries for :curate_batch_data_mount_path and :curate_batch_queue_mount_path.
      #      The following is the examples for the libvirt6 environment.
      #
      #        curate_batch_data_mount_path: /Volumes/curatend-batch/data/sipity/libvirt6
      #        curate_batch_queue_mount_path: /Volumes/curatend-batch/test/libvirt6/queue
      #
      #      * *Please review the directory structure of the mounted drive as that may have changed*
      #   3. Open up a Terminal window
      #      1. Change directory (cd) into the root of this Rails project
      #      2. Run the following command to send for ingest
      #         `rails runner "Sipity::Jobs::Core::BulkIngestJob.call(work_area_slug: 'etd', initial_processing_state_name: 'ready_for_ingest', processing_action_name: 'submit_for_ingest')"`
      #      3. Run the following command to send for ingest
      #         `rails runner "Sipity::Jobs::Core::BulkIngestJob.call(work_area_slug: 'etd', initial_processing_state_name: 'ready_for_doi_minting', processing_action_name: 'submit_for_doi_minting')"`
      #     4. Review the mounted queue subdirectories (i.e. `/Volumes/curatend-batch/test/libvirt6/queue`) for successes and failures
      #
      #   In some cases you may need to make changes to address that you don't have a copy of the attachments, see
      #   Sipity::Models::Attachment for more information on how to do this.
      #
      # @see Sipity::Models::Attachment for information on faking attached files.
      # @see https://github.com/ndlib/curatend-batch curatend-batch
      class BulkIngestJob
        def self.call(work_area_slug:, initial_processing_state_name:, processing_action_name:, **keywords)
          new(work_area_slug: work_area_slug,
              initial_processing_state_name: initial_processing_state_name,
              processing_action_name: processing_action_name,
              **keywords).call
        end

        ATTRIBUTE_NAMES = [
          :requested_by, :repository, :work_ingester, :search_criteria_builder, :exception_handler
        ].freeze

        def initialize(work_area_slug:, initial_processing_state_name:, processing_action_name:, **keywords)
          self.work_area_slug = work_area_slug
          self.initial_processing_state_name = initial_processing_state_name
          self.processing_action_name = processing_action_name
          ATTRIBUTE_NAMES.each do |attribute_name|
            send("#{attribute_name}=", keywords.fetch(attribute_name) { send("default_#{attribute_name}") })
          end
          set_search_criteria!
        end

        include Conversions::ConvertToWork
        def call
          works_in_error = []
          repository.find_works_via_search(criteria: search_criteria).each do |work_like|
            work = convert_to_work(work_like)
            next if submit_to_ingester(work: work)
            # Let's get a fresh version of the work
            work.reload
            works_in_error << work
          end
          return true if works_in_error.empty?
          report_batch_ingest_error(works: works_in_error)
        end

        private

        def report_batch_ingest_error(works:)
          exception = Exceptions::ScheduledJobError.new(works: works)
          exception_handler.call(exception, extra: { parameters: { processing_action_name: processing_action_name, initial_processing_state_name: initial_processing_state_name, job_class: self.class } })
        end

        def submit_to_ingester(work:)
          parameters = {
            work_id: work.id, requested_by: requested_by, processing_action_name: processing_action_name, attributes: ingester_attributes
          }
          begin
            ActiveRecord::Base.transaction { work_ingester.call(parameters) }
            return true
          rescue StandardError => exception
            exception_handler.call(exception, extra: { parameters: parameters.merge(work_ingester: work_ingester, job_class: self.class) })
            return false
          end
        end

        attr_reader :search_criteria

        def set_search_criteria!
          @search_criteria = search_criteria_builder.call(
            user: requested_by, processing_state: initial_processing_state_name, work_area: work_area_slug, per: 1000
          )
        end

        attr_accessor :search_criteria_builder

        def default_search_criteria_builder
          require 'sipity/parameters/search_criteria_for_works_parameter' unless defined?(Parameters::SearchCriteriaForWorksParameter)
          Parameters::SearchCriteriaForWorksParameter.method(:new)
        end

        attr_accessor :work_ingester

        def default_work_ingester
          require 'sipity/jobs/core/perform_action_for_work_job' unless defined?(Sipity::Jobs::Core::PerformActionForWorkJob)
          Sipity::Jobs::Core::PerformActionForWorkJob
        end

        attr_accessor :initial_processing_state_name

        attr_accessor :processing_action_name

        def ingester_attributes
          {}
        end

        attr_accessor :work_area_slug

        attr_accessor :exception_handler

        def default_exception_handler
          Raven.method(:capture_exception)
        end

        attr_accessor :requested_by

        def default_requested_by
          require 'sipity/models/group' unless defined?(Sipity::Models::Group)
          Sipity::Models::Group.find_by!(name: Sipity::Models::Group::BATCH_INGESTORS)
        end

        attr_accessor :repository

        def default_repository
          require 'sipity/query_repository' unless defined?(Sipity::QueryRepository)
          Sipity::QueryRepository.new
        end
      end
    end
  end
end
