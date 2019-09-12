namespace :development do
  namespace :etd do
    desc 'Add development entries for ETDs'
    task seed: [:environment, 'db:seed'] do
      require 'sipity/command_line_context'
      # Making an assumption that we have a user. We could use multiple, but roles
      # start to get far more complicated.
      user = User.first!
      context = Sipity::CommandLineContext.new(requested_by: user)
      submission_window = context.repository.find_open_submission_windows_by(work_area: 'etd').first!
      form_builder = Sipity::Forms::SubmissionWindows::Etd::StartASubmissionForm

      setup_form = form_builder.new(submission_window: submission_window, requested_by: context.requested_by, attributes: {})

      form = form_builder.new(
        submission_window: submission_window,
        requested_by: context.requested_by,
        attributes: {
          title: "Hello World",
          work_publication_strategy: setup_form.send(:possible_work_publication_strategies).sample,
          access_rights_answer: setup_form.send(:possible_access_right_codes).sample,
          work_type: setup_form.send(:possible_work_types).sample
        }
      )
      @work = form.submit
    end

    desc 'Create an entry in the ingesting state'
    task ingesting: ["development:etd:seed"] do
      Sipity::Services::Administrative::ForceIntoProcessingState.call(entity: @work, state: "ingesting")
    end

    desc 'Verify the callback URL against a running Rails server'
    task mark_as_complete: ["development:etd:ingesting"] do
      strategy_state_name = @work.processing_entity.reload.strategy_state.name
      if strategy_state_name != "ingesting"
        raise %(Expected work ID="#{@work.to_param}" to be 'ingesting')
      end
      callback_url = Sipity::Exporters::BatchIngestExporter::WebhookWriter.callback_url(work_id: @work.to_param)
      json = { "host" => Figaro.env.domain_name!, "version" => "1.0.1", "job_name" => "ingest-#{@work.to_param}", "job_state" => "success" }
      begin
        RestClient.post(URI.encode(callback_url), JSON.dump(json))
      rescue Errno::ECONNREFUSED => e
        $stderr.puts %(\n\nTo test this task, you need to have a local server running. Use "bin/rails s" in another terminal)
        raise e
      end
      strategy_state_name = @work.processing_entity.reload.strategy_state.name
      if strategy_state_name != "ingested"
        raise "Expected work ID=#{@work.to_param} to be 'ingested'"
      end
      $stdout.puts(%(\n\nSuccessfully transitioned work ID="#{@work.to_param}" from "ingesting" to "ingested" state))
    end
  end

  desc 'Add development entries for ULRA (you may want to run `rake bootstrap` beforehand)'
  task seed_ulra: [:environment, 'db:seed'] do
    require 'sipity/command_line_context'
    # Making an assumption that we have a user. We could use multiple, but roles
    # start to get far more complicated.
    user = User.first!

    # The default context is assumed to be a Rails controller. Instead use the
    # command line context, and thus build the entries through much the same
    # process as if it were done through the controller. Note this context
    # skips authentication/authorization (which you'd need to use something like
    # Sipity::Jobs::Core::PerformActionForWorkJob)
    context = Sipity::CommandLineContext.new(requested_by: user)
    submission_window = context.repository.find_open_submission_windows_by(work_area: 'ulra').first!
    form_builder = Sipity::Forms::SubmissionWindows::Ulra::StartASubmissionForm

    setup_form = form_builder.new(
      submission_window: submission_window,
      requested_by: context.requested_by,
      attributes: {}
    )
    # I want to test pagination in particular
    (1..20).each do |index|

      form = form_builder.new(
        submission_window: setup_form.submission_window,
        requested_by: context.requested_by,
        attributes: {
          title: "Hello World #{index}",
          award_category: setup_form.award_categories_for_select.sample,
          advisor_netid: 'jfriesen',
          advisor_name: 'Jeremy Friesen',
          course_name: 'My Course',
          course_number: "My Course Number"
        }
      )
      form.submit
    end
  end
end
