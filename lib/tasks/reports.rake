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
  * days             => number of days to scan backwards (defaults to 1)
  * hours            => number of hours to scan backwards (defaults to disabled)
  * environment      => Report only for hosts which belongs to a certian environment
  * fact=name:value  => Report only for hosts which have a certian fact name and a value
  * email            => override default email addresses

  Example:
    # Sends out a summary email for the last 3 days.
    rake reports:summarize days=3 RAILS_ENV="production" # Sends out a summary email for the last 3 days.

    # Sends out a summary email for the last 12 hours.
    rake reports:summarize hours=12 RAILS_ENV="production" # Sends out a summary email for the last 12 hours.

    # Sends out a summary email only for hosts which belongs to production puppet environment
    rake reports:summarize environment=production RAILS_ENV="production"

    # Sends out a summary email only for hosts which has a certian fact name and a value
    rake reports:summarize fact=domain:theforeman.org RAILS_ENV="production"

    # Sends out a summary email only for hosts which belongs to testing puppet environment to a special email address
    rake reports:summarize environment=testing email=testuser@domain RAILS_ENV="production"
END_DESC
namespace :reports do
  task :summarize => :environment do
    options = {}

    time = ENV['hours'].to_i.hours.ago if ENV['hours']
    time = ENV['days'].to_i.days.ago if ENV['days']
    options[:time] = time if time

    env = ENV['environment']
    unless env.empty?
      unless (e=Environment.find_by_name(env))
        $stdout.puts "Unable to find puppet environment=#{env}"
        exit 1
      end
      options[:env] = e if e
    end

    unless ENV['fact'].empty?
      name,value = ENV['fact'].split(":")
      fact = {name => value}
      if name.empty? or value.empty?
        $stdout.puts "invalid fact #{ENV['fact']}"
        exit 1
      end
      options[:factname] = name
      options[:factvalue] = value
    end

    options[:email] = ENV['email'] if ENV['email']

    HostMailer.deliver_summary(options)
  end
end
