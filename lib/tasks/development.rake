namespace :development do
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

    # I want to test pagination in particular
    (1..20).each do |index|
      setup_form = form_builder.new(
        submission_window: submission_window,
        requested_by: context.requested_by,
        attributes: {}
      )

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
