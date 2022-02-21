require 'csv'

namespace :host_reports do
  task :export => :environment do
    CSV.open("reports.csv", "w") do |csv|
      ConfigReport.all.each do |i|
        unless i.type == "ConfigReport" then next end
        if i.origin == "Ansible" then origin = "ansible" end
        if i.origin == "Puppet" then origin = "puppet" end
        csv << [i.id, i.host_id, i.reported_at, i.status.to_json,
          i.metrics.to_json, i.type, i.origin, i.logs, i.host]
      end
    end
  end
end
