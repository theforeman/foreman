namespace :interfaces do
  desc <<~END_DESC
    Removes old interfaces that match ignored interfaces pattern setting.

    This is useful when you change the ignored pattern setting.

    Examples:
      # foreman-rake interfaces:clean
  END_DESC

  task :clean => :environment do
    puts 'Starting ingnored interfaces clean up...'
    cleaner = InterfaceCleaner.new.clean!
    puts "Finished, cleaned #{cleaner.deleted_count} interfaces"
    unless cleaner.primary_hosts.empty?
      puts "Following hosts have ignored interface set as primary, please set other interface as primary and rerun the task:"
      print_host_queries(cleaner.primary_hosts)
    end
    unless cleaner.provision_hosts.empty?
      puts "Following hosts have ignored interface set as provision, please set other interface as provisioning and rerun the task:"
      print_host_queries(cleaner.provision_hosts)
    end
  end

  def print_host_queries(hosts)
    Host.unscoped.where(id: hosts.uniq).pluck(:name).in_groups_of(hosts_group_count, false) do |names|
      query = "name ^ (#{names.join(',')})"
      puts "#{Setting[:foreman_url]}#{helper.hosts_url(only_path: true, search: query)}"
    end
  end

  def hosts_group_count
    @hosts_group_count ||= (ENV['MAX_HOSTS'] || '50').to_i
  end

  def helper
    @helper ||= Rails.application.routes.url_helpers
  end
end
