# TRANSLATORS: do not translate
desc <<-END_DESC
Refresh the various statuses of all hosts

Available condition:
  * status_type => Class name of status type to refresh (e.g. BuildStatus or ConfigurationStatus)

END_DESC

namespace :status do
  task :refresh => :environment do
    User.current = User.anonymous_admin
    status_classes = HostStatus.status_registry
    status_classes = status_classes.select{|klass| klass.name.demodulize == ENV['status_type']} if ENV['status_type']
    raise "No host statuses found with class #{ENV['status_type']}" if status_classes.empty?

    Host::Managed.find_in_batches do |group|
      group.each do |host|
        status_classes.each do |status_class|
          if host.get_status(status_class).relevant?
            host.get_status(status_class).refresh
          end
        end
      end
    end
  end
end
