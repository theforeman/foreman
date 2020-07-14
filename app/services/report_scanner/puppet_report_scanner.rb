module Foreman
  class PuppetReportScanner
    class << self
      def identify_origin(report_data)
        'Puppet' if puppet_report?(report_data['logs'] || [])
      end

      def add_reporter_data(report, report_data)
        # no additional data apart of origin
      end

      def puppet_report?(logs)
        log = logs.last
        log && log['log'].fetch('sources', {}).fetch('source', '') =~ /Puppet/
      end
    end
  end
end
