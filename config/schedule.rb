# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
#
# Learn more: http://github.com/javan/whenever

# DLTP-1515 bundle was not being found by cron"

# to test in development using :files, change the default ingest method in base_exporter.
# use: bundle exec rails runner.... to run one of the commands below.
# complete ingest process by referring to example in scripts/one-offs/callback.rb
set :bundle_command, "/usr/local/bin/bundle exec"

if @environment == 'production' || @environment == 'prep'
  set :output, '/home/app/sipity/shared/log/cron_log.log'
  # I prefer to choose prime number moments in time for scheduling because other
  # people tend to schedule tasks on the quarter hours.
  # "I am the cicada, coo coo ca choo"

  every 1.day, at: '3:17 am', roles: [:app] do
    runner "Sipity::Jobs::Core::BulkIngestJob.call(work_area_slug: 'etd', initial_processing_state_name: 'ready_for_ingest', processing_action_name: 'submit_for_ingest')"
  end

  every 1.day, at: '1:11 am', roles: [:app] do
    runner "Sipity::Jobs::Core::BulkIngestJob.call(work_area_slug: 'etd', initial_processing_state_name: 'ready_for_doi_minting', processing_action_name: 'submit_for_doi_minting')"
  end
end
