require_dependency File.expand_path('../../../services/report_scanner/puppet_report_scanner', __dir__)

module Foreman
  class Plugin
    class ReportScannerRegistry
      DEFAULT_REPORT_SCANNERS = [
        ::Foreman::PuppetReportScanner,
      ].freeze

      attr_accessor :report_scanners

      def initialize
        @report_scanners = []
        register_default_scanner
      end

      def report_scanners
        @report_scanners ||= []
      end

      def register_report_scanner(scanner)
        @report_scanners = (report_scanners << scanner).uniq
      end

      def unregister_report_scanner(scanner)
        @report_scanners -= [scanner]
      end

      private

      def register_default_scanner
        DEFAULT_REPORT_SCANNERS.each do |default_scanner|
          register_report_scanner default_scanner
        end
      end
    end
  end
end
