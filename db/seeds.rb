# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html

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
      ['program', 'Aerospace and Mechanical Engineering', 'AME'],
      ['program', 'Anthropology', 'ANTH'],
      ['program', 'Applied and Computational Mathematics and Statistics', 'ACMS'],
      ['program', 'Art, Art History, and Design', 'ART'],
      ['program', 'Bioengineering', 'BIOE'],
      ['program', 'Biological Sciences', 'BIOS'],
      ['program', 'Chemical and Biomolecular Engineering', 'CBE, CHEG'],
      ['program', 'Civil and Environmental Engineering and Earth Sciences', 'Civil Engineering and Geological Sciences, CEEES, CEGS'],
      ['program', 'Chemistry', 'CHEM'],
      ['program', 'Classics', 'CLAS'],
      ['program', 'Computer Science and Engineering', 'CSE'],
      ['program', 'Creative Writing', 'CW, ENGL-CW'],
      ['program', 'Economics', 'Economics and Econometrics, ECON'],
      ['program', 'Early Christian Studies', 'ECS'],
      ['program', 'Electrical Engineering', 'EE'],
      ['program', 'English', 'ENGL'],
      ['program', 'History', 'HIST'],
      ['program', 'History and Philosophy of Science', 'HPS'],
      ['program', 'Integrated Biomedical Sciences', 'IBMS'],
      ['program', 'Peace Studies', 'PEACE, IIPS'],
      ['program', 'Law', nil],
      ['program', 'Literature', 'PhD in Literature, LIT'],
      ['program', 'Mathematics', 'MATH'],
      ['program', 'Medieval Studies', 'Medieval Institute, MI, MS'],
      ['program', 'Philosophy', 'PHIL'],
      ['program', 'Physics', 'PHYS'],
      ['program', 'Political Science', 'POLS'],
      ['program', 'Psychology', 'PSY'],
      ['program', 'Romance Languages and Literatures', 'ROML'],
      ['program', 'Sacred Music', 'SACM'],
      ['program', 'Sociology', 'SOC'],
      ['program', 'Theology', 'THEO']
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
        etd_strategy_roles[role_name] = etd_strategy.strategy_roles.find_or_initialize_by(role: roles.fetch(role_name))
      end

      etd_strategy_roles.fetch('etd_reviewer').strategy_responsibilities.find_or_initialize_by(actor: graduate_school_actor)

      etd_states = {}
      [
        'new',
        'under_advisor_review',
        'advisor_changes_requested',
        'under_grad_school_review',
        'ready_for_ingest',
        'ingesting',
        'done'
      ].each do |state_name|
        etd_states[state_name] = etd_strategy.strategy_states.find_or_initialize_by(name: state_name)
      end

      etd_actions = {}
      [
        ['show', nil],
        ['edit', nil],
        ['destroy', nil],
        ['describe', nil],
        ['search_terms', nil],
        ['attach', nil],
        ['collaborators', nil],
        ['defense_date', nil],
        ['degree', nil],
        ['access_policy', nil],
        ['assign_a_doi', nil],
        ['assign_a_citation', nil],
        ['submit_for_review', 'under_advisor_review'],
        ['advisor_signoff', 'under_grad_school_review'],
        ['signoff_on_behalf_of', 'under_grad_school_review'],
        ['advisor_requests_change', 'advisor_changes_requested'],
        ['grad_school_requests_change', 'under_grad_school_review'],
        ['grad_school_signoff', 'ready_for_ingest'],
        ['ingest', 'ingesting'],
        ['ingest_completed', 'done']
      ].each do |action_name, strategy_state_name|
        resulting_state = strategy_state_name ? etd_states.fetch(strategy_state_name) : nil
        etd_actions[action_name] = etd_strategy.strategy_actions.find_or_initialize_by(
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
          guarded_action.requiring_strategy_action_prerequisites.build(prerequisite_strategy_action: prereq_action)
        end
      end


      [
        ['new', 'submit_for_review', ['creating_user']],
        ['new', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
        ['new', 'edit', ['creating_user', 'etd_reviewer']],
        ['new', 'describe', ['creating_user', 'etd_reviewer']],
        ['new', 'search_terms', ['creating_user', 'etd_reviewer']],
        ['new', 'attach', ['creating_user', 'etd_reviewer']],
        ['new', 'collaborators', ['creating_user', 'etd_reviewer']],
        ['new', 'destroy', ['creating_user', 'etd_reviewer']],
        ['new', 'defense_date', ['creating_user']],
        ['new', 'degree', ['creating_user']],
        ['new', 'access_policy', ['creating_user']],
        ['new', 'assign_a_doi', ['creating_user', 'etd_reviewer']],
        ['new', 'assign_a_citation', ['creating_user', 'etd_reviewer']],
        ['under_advisor_review', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
        ['under_advisor_review', 'assign_a_doi', ['etd_reviewer']],
        ['under_advisor_review', 'assign_a_citation', ['etd_reviewer']],
        ['under_advisor_review', 'destroy', ['etd_reviewer']],
        ['under_advisor_review', 'advisor_signoff', ['advisor']],
        ['under_advisor_review', 'signoff_on_behalf_of', ['etd_reviewer']],
        ['under_advisor_review', 'advisor_requests_change', ['etd_reviewer', 'advisor']],
        ['advisor_changes_requested', 'assign_a_doi', ['etd_reviewer', 'creating_user']],
        ['advisor_changes_requested', 'assign_a_citation', ['creating_user']],
        ['advisor_changes_requested', 'defense_date', ['creating_user']],
        ['advisor_changes_requested', 'degree', ['creating_user']],
        ['advisor_changes_requested', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
        ['advisor_changes_requested', 'edit', ['creating_user', 'etd_reviewer']],
        ['advisor_changes_requested', 'destroy', ['creating_user', 'etd_reviewer']],
        ['advisor_changes_requested', 'access_policy', ['creating_user']],
        ['under_grad_school_review', 'assign_a_doi', ['etd_reviewer']],
        ['under_grad_school_review', 'assign_a_citation', ['etd_reviewer']],
        ['under_grad_school_review', 'grad_school_requests_change', ['etd_reviewer']],
        ['under_grad_school_review', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
        ['under_grad_school_review', 'grad_school_signoff', ['etd_reviewer']],
        ['under_grad_school_review', ['edit', 'destroy'], ['etd_reviewer']],
        ['ready_for_ingest', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
        ['ingesting', 'show', ['creating_user', 'advisor', 'etd_reviewer']],
        ['done', 'show', ['creating_user', 'advisor', 'etd_reviewer']]
      ].each do |originating_state_name, action_names, role_names|
        Array.wrap(action_names).each do |action_name|
          action = etd_actions.fetch(action_name)
          originating_state = etd_states.fetch(originating_state_name)
          event = action.strategy_state_actions.find_or_initialize_by(originating_strategy_state: originating_state)

          Array.wrap(role_names).each do |role_name|
            etd_strategy_roles.fetch(role_name).strategy_state_action_permissions.find_or_initialize_by(strategy_state_action: event)
          end
        end
      end
    end.save!
  end
end
