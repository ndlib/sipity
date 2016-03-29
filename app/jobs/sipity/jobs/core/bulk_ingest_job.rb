module Sipity
  module Jobs
    module Core
      # Responsible for managing the ingest of each and every work in the :work_area_slug that is in the :initial_processing_state_name.
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
      #      2. Run the following command `rails runner "Sipity::Jobs::Core::BulkIngestJob.call(work_area_slug: 'etd')""`
      #   4. Review the mounted queue subdirectories (i.e. `/Volumes/curatend-batch/test/libvirt6/queue`) for successes and failures
      #
      #   In some cases you may need to make changes to address that you don't have a copy of the attachments, see
      #   Sipity::Models::Attachment for more information on how to do this.
      #
      # @see Sipity::Models::Attachment for information on faking attached files.
      # @see https://github.com/ndlib/curatend-batch curatend-batch
      class BulkIngestJob
        def self.call(work_area_slug:, **keywords)
          new(work_area_slug: work_area_slug, **keywords).call
        end

        ATTRIBUTE_NAMES = [
          :requested_by, :repository, :initial_processing_state_name, :work_ingester, :search_criteria_builder,
          :processing_action_name, :exception_handler
        ].freeze

        def initialize(work_area_slug:, **keywords)
          self.work_area_slug = work_area_slug
          ATTRIBUTE_NAMES.each do |attribute_name|
            send("#{attribute_name}=", keywords.fetch(attribute_name) { send("default_#{attribute_name}") })
          end
          set_search_criteria!
        end

        include Conversions::ConvertToWork
        def call
          repository.find_works_via_search(criteria: search_criteria).each do |work_like|
            ingest(work: convert_to_work(work_like))
          end
        end

        private

        def ingest(work:)
          parameters = {
            work_id: work.id, requested_by: requested_by, processing_action_name: processing_action_name, attributes: ingester_attributes
          }
          begin
            ActiveRecord::Base.transaction { work_ingester.call(parameters) }
          rescue StandardError => exception
            exception_handler.call(exception, parameters: parameters.merge(work_ingester: work_ingester, job_class: self.class))
          end
        end

        attr_reader :search_criteria

        def set_search_criteria!
          @search_criteria = search_criteria_builder.call(
            user: requested_by, processing_state: initial_processing_state_name, work_area: work_area_slug, page: :all
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

        # @note This is an assumption based on the ETD and ULRA work submission work flows.
        def default_initial_processing_state_name
          'ready_for_ingest'
        end

        attr_accessor :processing_action_name

        # @see Sipity::Forms::WorkSubmissionsCore::SubmitForIngestForm
        def default_processing_action_name
          'submit_for_ingest'
        end

        def ingester_attributes
          { exporter: work_area_slug }
        end

        attr_accessor :work_area_slug

        attr_accessor :exception_handler

        def default_exception_handler
          Airbrake.method(:notify_or_ignore)
        end

        attr_accessor :requested_by

        def default_requested_by
          require 'sipity/models/group' unless defined?(Sipity::Models::Group)
          Sipity::Models::Group.batch_ingestors
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
