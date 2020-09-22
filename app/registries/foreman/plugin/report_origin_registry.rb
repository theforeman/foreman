module Foreman
  class Plugin
    class ReportOriginRegistry
      DEFAULT_ORIGIN_REPORT_CLASS = 'Report'.freeze
      DEFAULT_REPORT_ORIGINS = {
        'ConfigReport' => ['Puppet'],
      }.freeze

      attr_accessor :report_origins

      def initialize
        @report_origins = DEFAULT_REPORT_ORIGINS.dup
      end

      def register(origin, report_class = DEFAULT_ORIGIN_REPORT_CLASS)
        @report_origins[report_class] ||= []
        @report_origins[report_class] << origin
      end
      alias_method :register_report_origin, :register

      def origins_for(report_class = DEFAULT_ORIGIN_REPORT_CLASS)
        @report_origins[report_class.to_s]
      end

      def all_origins
        @report_origins.map { |_, origins| origins }.sum
      end

      def origins_with_interval_setting
        Hash[all_origins.map do |origin|
          interval_setting = Setting[:"#{origin.downcase}_interval"]
          [origin, (interval_setting || default_interval).to_i]
        end]
      end

      private

      def default_interval
        Setting[:outofsync_interval]
      end
    end
  end
end
