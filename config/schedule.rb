# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
#
# Learn more: http://github.com/javan/whenever

if @environment == 'production'
  set :output, "/home/app/sipity/shared/log/cron_log.log"
  # I prefer to choose prime number moments in time for scheduling because other
  # people tend to schedule tasks on the quarter hours.
  # "I am the cicada, coo coo ca choo"
  every 1.day, at: '3:17 am', roles: [:app] do
    runner "Sipity::Jobs::Core::BulkIngestJob.call(work_area_slug: 'etd')"
  end
end
