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
        log = logs.last
        log && log['log'].fetch('sources', {}).fetch('source', '') =~ /Puppet/
      end
    end
  end
end
