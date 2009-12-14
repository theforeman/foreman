desc <<-END_DESC
Expire Reports automatically

Available conditions:
  * days     => number of days to keep reports (defaults to 7)
  * status   => status of the report (defaults to 0 --> "reports with no errors")

  Example:
    rake reports:expire days=7 RAILS_ENV="production" # expires all reports regardless of their status
    rake reports:expire days=1 status=0 RAILS_ENV="production" # expires all non interesting reports after one day

END_DESC

namespace :reports do
  task :expire => :environment do
    conditions = {}
    conditions[:timerange] = ENV['days'].to_i.days if ENV['days']
    conditions[:status] = ENV['status'].to_i if ENV['status']

    Report.expire(conditions)
  end
end
desc <<-END_DESC
Send an email summarising hosts reports (and lack of it).

Available conditions:
  * days     => number of days to scan backwards (defaults to 1)
  * hours    => number of hours to scan backwards (defaults to disabled)

  Example:
    rake reports:summarize days=3 RAILS_ENV="production" # Sends out a summary email for the last 3 days.
    rake reports:summarize hours=12 RAILS_ENV="production" # Sends out a summary email for the last 12 hours.

END_DESC
namespace :reports do
  task :summarize => :environment do
    
    time = ENV['hours'].to_i.hours.ago if ENV['hours'] 
    time = ENV['days'].to_i.days.ago if ENV['days'] 
    time = 1.days.ago unless time
    HostMailer.deliver_summary(time, Host.all)
  end
end
