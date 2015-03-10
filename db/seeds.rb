# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html

# A helpful method for making sure that we are building the nested data correctly.
def find_or_initialize_or_create!(attributes = {})
  context = attributes.fetch(:context)
  receiver = attributes.fetch(:receiver)
  method_name = context.persisted? ? :find_or_create_by! : :find_or_initialize_by
  receiver.send(method_name, attributes.except(:context, :receiver))
end

ActiveRecord::Base.transaction do
  $stdout.puts 'Creating Work Types...'
  work_types = {}
  Sipity::Models::WorkType.valid_names.each do |work_type_name|
    work_types[work_type_name] = Sipity::Models::WorkType.find_or_create_by!(name: work_type_name)
  end


  graduate_school_group = Sipity::Models::Group.find_or_create_by!(name: 'Graduate School Reviewers')
  graduate_school_actor = Sipity::Conversions::ConvertToProcessingActor.call(graduate_school_group)

  $stdout.puts 'Creating ETD Reviewer Role...'
  roles = {}

  [
    'creating_user',
    'etd_reviewer',
    'advisor'
  ].each do |role_name|
    roles[role_name] = Sipity::Models::Role.find_or_create_by!(name: role_name)
  end


  $stdout.puts 'Creating degree names...'
  degree_names =
  [
    ['degree', 'Doctor of Musical Arts', 'DMA'],
    ['degree', 'Doctor of Philosophy', 'PhD'],
    ['degree', 'Master of Arts', 'MA'],
    ['degree', 'Master of Fine Arts', 'MFA'],
    ['degree', 'Master of Medieval Studies', 'MMS'],
    ['degree', 'Master of Science', 'MS'],
    ['degree', 'Master of Science in Aerospace Engineering', 'MSAE'],
    ['degree', 'Master of Science in Bioengineering', 'MSBioE'],
    ['degree', 'Master of Science in Chemical Engineering', 'MSChE'],
    ['degree', 'Master of Science in Civil Engineering', 'MSCE'],
    ['degree', 'Master of Science in Computer Science and Engineering', 'MSCSE'],
    ['degree', 'Master of Science in Earth Sciences', 'MSES'],
    ['degree', 'Master of Science in Electrical Engineering', 'MSEE'],
    ['degree', 'Master of Science in Environmental Engineering', 'MSEnvE'],
    ['degree', 'Master of Science in Geological Sciences', 'MSGS'],
    ['degree', 'Master of Science in Interdisciplinary Mathematics', 'MSIM'],
    ['degree', 'Master of Science in Mechanical Engineering', 'MSME']
  ]
  degree_names.each do |predicate_name, predicate_value, predicate_value_code|
    Sipity::Models::SimpleControlledVocabulary.find_or_create_by!(
    predicate_name: predicate_name, predicate_value: predicate_value, predicate_value_code: predicate_value_code)
  end

  $stdout.puts 'Creating program names...'
  program_names =
  [
    ['program_name', 'Aerospace and Mechanical Engineering', 'AME'],
    ['program_name', 'Anthropology', 'ANTH'],
    ['program_name', 'Applied and Computational Mathematics and Statistics', 'ACMS'],
    ['program_name', 'Art, Art History, and Design', 'ART'],
    ['program_name', 'Bioengineering', 'BIOE'],
    ['program_name', 'Biological Sciences', 'BIOS'],
    ['program_name', 'Chemical and Biomolecular Engineering', 'CBE, CHEG'],
    ['program_name', 'Civil and Environmental Engineering and Earth Sciences', 'Civil Engineering and Geological Sciences, CEEES, CEGS'],
    ['program_name', 'Chemistry', 'CHEM'],
    ['program_name', 'Classics', 'CLAS'],
    ['program_name', 'Computer Science and Engineering', 'CSE'],
    ['program_name', 'Creative Writing', 'CW, ENGL-CW'],
    ['program_name', 'Economics', 'Economics and Econometrics, ECON'],
    ['program_name', 'Early Christian Studies', 'ECS'],
    ['program_name', 'Electrical Engineering', 'EE'],
    ['program_name', 'English', 'ENGL'],
    ['program_name', 'History', 'HIST'],
    ['program_name', 'History and Philosophy of Science', 'HPS'],
    ['program_name', 'Integrated Biomedical Sciences', 'IBMS'],
    ['program_name', 'Peace Studies', 'PEACE, IIPS'],
    ['program_name', 'Law', nil],
    ['program_name', 'Literature', 'PhD in Literature, LIT'],
    ['program_name', 'Mathematics', 'MATH'],
    ['program_name', 'Medieval Studies', 'Medieval Institute, MI, MS'],
    ['program_name', 'Philosophy', 'PHIL'],
    ['program_name', 'Physics', 'PHYS'],
    ['program_name', 'Political Science', 'POLS'],
    ['program_name', 'Psychology', 'PSY'],
    ['program_name', 'Romance Languages and Literatures', 'ROML'],
    ['program_name', 'Sacred Music', 'SACM'],
    ['program_name', 'Sociology', 'SOC'],
    ['program_name', 'Theology', 'THEO']
  ]
  program_names.each do |predicate_name, predicate_value, predicate_value_code|
    Sipity::Models::SimpleControlledVocabulary.find_or_create_by!(
    predicate_name: predicate_name, predicate_value: predicate_value, predicate_value_code: predicate_value_code)
  end

  $stdout.puts 'Creating ETD State Diagram...'
  ['doctoral_dissertation', 'master_thesis'].each do |work_type_name|
    work_types.fetch(work_type_name).find_or_initialize_default_processing_strategy do |etd_strategy|
      etd_strategy_roles = {}

      [
        'creating_user',
        'etd_reviewer',
        'advisor'
      ].each do |role_name|
        etd_strategy_roles[role_name] = find_or_initialize_or_create!(
          context: etd_strategy,
          receiver: etd_strategy.strategy_roles,
          role: roles.fetch(role_name)
        )
      end

      etd_reviewer = etd_strategy_roles.fetch('etd_reviewer')

      find_or_initialize_or_create!(
        context: etd_reviewer,
        receiver: etd_reviewer.strategy_responsibilities,
        actor: graduate_school_actor
      )

      etd_states = {}
      [
        'new',
        'under_advisor_review',
        'advisor_changes_requested',
        'under_grad_school_review',
        'ready_for_ingest'
      ].each do |state_name|
        etd_states[state_name] = find_or_initialize_or_create!(
          context: etd_strategy,
          receiver: etd_strategy.strategy_states,
          name: state_name
        )
      end

      etd_actions = {}
      [
        ['show', nil],
        ['destroy', nil],
        ['describe', nil],
        ['search_terms', nil],
        ['attach', nil],
        ['collaborators', nil],
        ['defense_date', nil],
        ['degree', nil],
        ['access_policy', nil],
        ['submit_for_review', 'under_advisor_review'],
        ['advisor_signoff', 'under_grad_school_review'],
        ['signoff_on_behalf_of', 'under_grad_school_review'],
        ['advisor_requests_change', 'advisor_changes_requested'],
        ['grad_school_requests_change', 'under_grad_school_review'],
        ['grad_school_signoff', 'ready_for_ingest']
      ].each do |action_name, strategy_state_name|
        resulting_state = strategy_state_name ? etd_states.fetch(strategy_state_name) : nil
        etd_actions[action_name] = find_or_initialize_or_create!(
          context: etd_strategy,
          receiver: etd_strategy.strategy_actions,
          name: action_name, resulting_strategy_state: resulting_state
        )
      end

      pre_requisite_states =       {
        'submit_for_review' => ['describe', 'degree', 'attach', 'collaborators', 'access_policy']
      }

      if work_type_name == 'doctoral_dissertation'
        pre_requisite_states['submit_for_review'] << 'defense_date'
      end

      pre_requisite_states.each do |guarded_action_name, prereq_action_names|
        guarded_action = etd_actions.fetch(guarded_action_name)
        Array.wrap(prereq_action_names).each do |prereq_action_name|
          prereq_action = etd_actions.fetch(prereq_action_name)
          find_or_initialize_or_create!(
            context: guarded_action,
            receiver: guarded_action.requiring_strategy_action_prerequisites,
            prerequisite_strategy_action: prereq_action
          )
        end
      end


      [
        ['new', 'submit_for_review', ['creating_user']],
        ['new', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
        ['new', 'describe', ['creating_user', 'etd_reviewer']],
        ['new', 'search_terms', ['creating_user', 'etd_reviewer']],
        ['new', 'attach', ['creating_user', 'etd_reviewer']],
        ['new', 'collaborators', ['creating_user', 'etd_reviewer']],
        ['new', 'destroy', ['creating_user', 'etd_reviewer']],
        ['new', 'defense_date', ['creating_user']],
        ['new', 'degree', ['creating_user']],
        ['new', 'access_policy', ['creating_user']],
        ['under_advisor_review', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
        ['under_advisor_review', 'destroy', ['etd_reviewer']],
        ['under_advisor_review', 'advisor_signoff', ['advisor']],
        ['under_advisor_review', 'signoff_on_behalf_of', ['etd_reviewer']],
        ['under_advisor_review', 'advisor_requests_change', ['etd_reviewer', 'advisor']],
        ['advisor_changes_requested', 'submit_for_review', ['creating_user']],
        ['advisor_changes_requested', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
        ['advisor_changes_requested', 'describe', ['creating_user', 'etd_reviewer']],
        ['advisor_changes_requested', 'search_terms', ['creating_user', 'etd_reviewer']],
        ['advisor_changes_requested', 'attach', ['creating_user', 'etd_reviewer']],
        ['advisor_changes_requested', 'collaborators', ['creating_user', 'etd_reviewer']],
        ['advisor_changes_requested', 'destroy', ['creating_user', 'etd_reviewer']],
        ['advisor_changes_requested', 'defense_date', ['creating_user']],
        ['advisor_changes_requested', 'degree', ['creating_user', 'etd_reviewer']],
        ['advisor_changes_requested', 'access_policy', ['creating_user', 'etd_reviewer']],
        ['under_grad_school_review', 'grad_school_requests_change', ['etd_reviewer']],
        ['under_grad_school_review', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
        ['under_grad_school_review', 'grad_school_signoff', ['etd_reviewer']],
        ['under_grad_school_review', ['destroy'], ['etd_reviewer']],
        ['ready_for_ingest', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
      ].each do |originating_state_name, action_names, role_names|
        Array.wrap(action_names).each do |action_name|
          action = etd_actions.fetch(action_name)
          originating_state = etd_states.fetch(originating_state_name)
          event = find_or_initialize_or_create!(
            context: action,
            receiver: action.strategy_state_actions,
            originating_strategy_state: originating_state
          )

          Array.wrap(role_names).each do |role_name|
            strategy_role = etd_strategy_roles.fetch(role_name)
            find_or_initialize_or_create!(
              context: strategy_role,
              receiver: strategy_role.strategy_state_action_permissions,
              strategy_state_action: event
            )
          end
        end
      end
    end.save!
  end
end
