# TRANSLATORS: do not translate
desc <<~END_DESC
  Expire Reports automatically

  Available conditions:
    * days        => number of days to keep reports (defaults to 7)
    * status      => status of the report (if not set defaults to any status)
    * report_type => report type (defaults to config_report), accepts either underscore / class name styles
    * batch_size  => number of records deleted in single SQL transaction (defaults to 1k)
    * sleep_time  => delay in seconds between batches (defaults to 0.2)

    Example:
      rake reports:expire days=7 RAILS_ENV="production" # expires all reports regardless of their status
      rake reports:expire days=1 status=0 RAILS_ENV="production" # expires all non interesting reports after one day
      rake reports:expire report_type=my_report days=3 # expires all reports of type MyReport (underscored style) from the last 3 days.
      rake reports:expire report_type=MyReport days=3 # expires all reports of type MyReport (class name style) from the last 3 days.

END_DESC
namespace :reports do
  def report_type
    return ConfigReport if ENV['report_type'].blank?
    begin
      ENV['report_type'].camelize.constantize
    rescue NameError => e
      puts "Could not find a report of type #{ENV['report_type']}, please check spelling / underscore errors"
      raise e
    end
  end

  task :expire => :environment do
    conditions = {}
    conditions[:timerange] = ENV['days'].to_i.days if ENV['days']
    conditions[:status] = ENV['status'].to_i if ENV['status']
    batch_size = 1000
    batch_size = ENV['batch_size'].to_i if ENV['batch_size']
    sleep_time = 0.2
    sleep_time = ENV['sleep_time'].to_f if ENV['sleep_time']

    User.as_anonymous_admin do
      report_type.expire(conditions, batch_size, sleep_time)
    end
  end
end

# TRANSLATORS: do not translate
desc <<~END_DESC
  Send an email notifications such as summarising hosts Puppet reports (and lack of it), audits summaries, built hosts summary etc.

  Users can configure the frequency they desire to receive mail notifications under
  My account -> Mail Preferences -> Notifications, and this task will send emails to
  users according to their preferences.
  e.g: rake reports:daily sends reports to users who want daily notifications.

  Available conditions:
    * days             => number of days to scan backwards (defaults to 1)
    * hours            => number of hours to scan backwards (defaults to disabled)
    * environment      => Report only for hosts which belongs to a certian environment
    * fact=name:value  => Report only for hosts which have a certian fact name and a value
    * email            => override default email addresses

    Example:
      # Sends out a monthly summary email only for hosts that belong in the 'production' environment
      rake reports:monthly environment=production RAILS_ENV="production"

      # Sends out a weekly summary email only for hosts matching a certain fact name and value
      rake reports:weekly fact=domain:theforeman.org RAILS_ENV="production"

      # Sends out a weekly summary email containing only hosts that belong in the 'testing'
      # environment to an email address 'testuser@domain'
      rake reports:weekly environment=testing email=testuser@domain RAILS_ENV="production"
END_DESC
namespace :reports do
  def mail_options
    options = {}

    time = ENV['hours'].to_i.hours.ago if ENV['hours']
    time = ENV['days'].to_i.days.ago if ENV['days']
    options[:time] = time if time

    env = ENV['environment']
    unless env.empty?
      unless (e = Environment.find_by_name(env))
        $stdout.puts "Unable to find puppet environment=#{env}"
        exit 1
      end
      options[:env] = e if e
    end

    unless ENV['fact'].empty?
      name, value = ENV['fact'].split(":")
      if name.empty? || value.empty?
        $stdout.puts "invalid fact #{ENV['fact']}"
        exit 1
      end
      options[:factname] = name
      options[:factvalue] = value
    end

    options[:email] = ENV['email'] if ENV['email']
    options
  end

  def process_notifications(interval)
    User.as_anonymous_admin do
      UserMailNotification.public_send(interval).each do |notification|
        notification.deliver(mail_options)
      end
    end
  end

  task :daily => :'dynflow:client' do
    process_notifications :daily
  end

  task :weekly => :'dynflow:client' do
    process_notifications :weekly
  end

  task :monthly => :'dynflow:client' do
    process_notifications :monthly
  end
end
