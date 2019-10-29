desc 'Rescan existing reports without origin and tries to find correct origin'
task :rescan_reports_origins => :environment do
  puts "Scanning #{ConfigReport.count} reports, this can take a long time, it's safe to interrupt and rerun later..."
  User.as_anonymous_admin do
    ConfigReport.where(:origin => nil).includes(:logs => [:source, :message]).find_in_batches(batch_size: 100) do |group|
      group.each do |report|
        Foreman::Plugin.report_scanner_registry.report_scanners.each do |scanner|
          logs = report.logs.map do |log|
            {'log' =>
               {
                 'sources' => { 'source' => log.source.value },
                 'messages' => { 'message' => log.message.value },
               },
            }
          end

          scanner.scan(report, logs)
          report.save! if report.origin_changed?
        end
      end
    end
  end
end
