# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
 env :PATH, ENV['PATH']
 env :GEM_PATH, ENV['GEM_PATH']
 job_type :runner, "cd :path && bundle exec rails runner -e :environment ':task' :output"
 set :output, "log/whenever.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

every :monday, at: '9:00 am'  do 
  runner "WeeklyMailer.weekly_mailer(User.where(weekly_mailer: true)).deliver"
end
# Learn more: http://github.com/javan/whenever
