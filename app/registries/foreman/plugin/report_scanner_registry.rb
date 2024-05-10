module Foreman
  class Plugin
    class ReportScannerRegistry
      attr_accessor :report_scanners

      def initialize
        @report_scanners = []
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
    end
  end
end
