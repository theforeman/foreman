module Foreman
  class PuppetReportScanner
    class << self
      def origin
        'Puppet'
      end

      def identify_origin(report_data)
        self.origin if puppet_report?(report_data)
      end

      def add_reporter_data(report, report_data)
        # no additional data apart of origin
      end

      def puppet_report?(report)
        report['logs']&.last&.dig('log', 'sources', 'source')&.match?(/Puppet/)
      end
    end
  end
end
