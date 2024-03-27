require_dependency File.expand_path('../../../services/report_scanner/puppet_report_scanner', __dir__)

module Foreman
  class Plugin
    class ReportScannerRegistry
      DEFAULT_REPORT_SCANNERS = [
        ::Foreman::PuppetReportScanner,
      ].freeze

      def initialize
        @report_scanners = {}
        register_default_scanner
      end

      def report_scanners
        @report_scanners.values
      end

      def origins
        @report_scanners.keys
      end

      def [](name)
        @report_scanners[name]
      end

      def register_report_scanner(scanner)
        @report_scanners[origin(scanner)] = scanner
      end

      def unregister_report_scanner(scanner)
        @report_scanners.delete(scanner)
      end

      private

      def origin(scanner)
        if scanner.respond_to?(:origin)
          scanner.origin
        else
          Foreman::Deprecation.deprecation_warning('3.7', "Report scanner '#{scanner}' must declare an origin")
          scanner.class_name.delete_suffix('ReportScanner')
        end

      def register_default_scanner
        DEFAULT_REPORT_SCANNERS.each do |default_scanner|
          register_report_scanner default_scanner
        end
      end
    end
  end
end
