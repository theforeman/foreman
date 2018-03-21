module Foreman
  class PuppetReportScanner
    class << self
      def scan(report, logs)
        if (is_puppet = puppet_report?(logs))
          report.origin = 'Puppet'
        end
        is_puppet
      end

      def puppet_report?(logs)
        first_log = logs.first
        first_log && first_log['log'].fetch('sources', {}).fetch('source', '') =~ /Puppet/
      end
    end
  end
end
