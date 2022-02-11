require 'json'

namespace :host_reports do
    task :import => :environment do
        reports_json = File.read("reports.json")
        reports_hash = JSON.parse(reports_json)
        reports_hash.each do |i|
            ConfigReport.create(JSON.parse(i))
        end
    end
end
