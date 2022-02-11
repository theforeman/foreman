namespace :host_reports do
    task :export => :environment do
        reports = []
        ConfigReport.all.each do |i|
            reports << i.to_json
        end
        File.open("reports.json", "w") do |f|
            f.write(reports)
        end
    end
end
