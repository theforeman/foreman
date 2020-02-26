require "csv"

# Use 'foreman-rake db:schema:dump' to generate database schema and view it as
# '/usr/share/foreman/db/schema.rb' to find out table and column names.

# TRANSLATORS: do not translate
desc <<~END_DESC
  Database exporting

  This task converts data from the internal database to CSV format. Several export templates
  are provided defined in

      /usr/share/foreman/lib/tasks/exports.rake

  It is possible to define own templates via simple DSL and ActiveRecord API in:

      /etc/foreman/exporters.rb.conf

  Available conditions:
    * output => output directory
    * templates => particular templates to be exported (all by default)
    * header => generate column names (CSV only)

    Example:
      rake exports:csv ouput=/tmp/export header=1
      rake exports:csv templates=managed_hosts_provisioning_summary,other_template ouput=/tmp/export
END_DESC

$exporters = {}
def exporter_template(status, name, &proc)
  $exporters[name] = proc if status == :enabled
end

exporter_template(:enabled, :managed_hosts_provisioning_summary) do |header, data|
  header << ["Host", "Model", "Arch", "OS", "Medium", "Build", "Comment", "Compute resource"]
  Host::Managed.joins(:architecture, :operatingsystem, :medium)
    .joins("LEFT JOIN models ON hosts.model_id = models.id")
    .joins("LEFT JOIN compute_resources ON hosts.compute_resource_id = compute_resources.id")
    .pluck("name", "models.name", "architectures.name", "operatingsystems.description", "media.name", "build", "comment", "compute_resources.name")
    .each do |record|
    data << record
  end
end

exporter_template(:enabled, :managed_hosts_bootfiles) do |header, data|
  header << ["Host", "Boot files"]
  Host::Managed.all.find_each do |host|
    bootfiles = host.operatingsystem.send(:boot_files_uri, host.medium_provider) rescue []
    data << [
      host.name,
      bootfiles.join(' + '),
    ]
  end
end

exporter_template(:disabled, :discovered_hosts_summary) do |header, data|
  header << ["Host", "CPUs", "Memory", "Disks", "Subnet", "Booted IF", "MACs", "IPs", "Created", "Last report"]
  Host::Discovered.all.find_each do |record|
    facts = record.facts
    data << [
      record.name,
      record.cpu_count,
      record.memory,
      record.disk,
      record.subnet.name,
      facts["discovery_bootif"],
      facts.collect { |k, v| v if k =~ /macaddress/ }.compact.join(','),
      facts.collect { |k, v| v if k =~ /ipaddress/ }.compact.join(','),
      record.created_at,
      record.last_report,
    ]
  end
end

# load user-defined reports
USER_DEFINED_CONF = "/etc/foreman/exporters.rb.conf"
require USER_DEFINED_CONF if File.exist?(USER_DEFINED_CONF)

namespace :exports do
  task :csv => :environment do
    output = ENV['output'] || '.'
    only_templates = (ENV['templates'] || '').split(',').collect(&:to_sym)
    $exporters.each_pair do |exporter_name, exporter_proc|
      next if only_templates.count > 0 && !only_templates.include?(exporter_name)
      CSV.open(File.join(output, "#{exporter_name}.csv"), "wb") do |csv|
        header = ENV['header'] ? csv : []
        exporter_proc.call(header, csv)
      end
    end
  end
end
