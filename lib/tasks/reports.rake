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
