require 'ostruct'
require 'net/http'
require 'uri'

module Foreman
  module BootloaderUniverse
    class Download
      class InvalidRequest < StandardError; end

      HTTP_SOURCE_PROBE_TIMEOUT = 1
      HTTP_SOURCE_PROBE_MAX_REDIRECTS = 2
      HTTP_SCHEMES = %w[http https].freeze

      class MediumSource
        attr_reader :medium

        def initialize(operatingsystem, source)
          @operatingsystem = operatingsystem
          @medium = ::Medium.authorized(:view_media).find_by(id: source[:id])
          raise InvalidRequest, _('Installation medium was not found or is not visible') unless @medium
          unless @operatingsystem.media.exists?(@medium.id)
            raise InvalidRequest, _('Installation medium is not associated with this operating system')
          end
        end

        def description
          { type: 'medium', id: medium.id }
        end

        def architectures
          @operatingsystem.architectures.where(name: 'x86_64').to_a
        end

        def prefix_for(architecture)
          provider_for(architecture).boot_file_source_uri(operatingsystem: @operatingsystem, architecture: architecture).to_s
        end

        def legacy_provider_for(architecture)
          provider_for(architecture)
        end

        private

        def provider_for(architecture)
          entity = OpenStruct.new(operatingsystem: @operatingsystem, medium: medium, architecture: architecture)
          ::MediumProviders::Default.new(entity)
        end
      end

      attr_reader :operatingsystem, :source_params

      def initialize(operatingsystem:, source:, smart_proxy_ids: nil)
        @operatingsystem = operatingsystem
        @source_params = source.to_h.symbolize_keys
        @smart_proxy_ids = smart_proxy_ids
      end

      def self.universe_capable?(proxy, operatingsystem)
        return false unless proxy.has_feature?('TFTP')
        return false unless proxy.has_capability?(:TFTP, :bootloader_universe)

        archive_types = operatingsystem.bootloader_universe_archive_types
        return false if archive_types.empty?

        archive_types.all? { |type| proxy.has_capability?(:TFTP, "bootloader_archive_#{type}".to_sym) }
      end

      def call
        source = resolve_source
        plans = build_plans(source)
        proxies = selected_proxies
        has_universe_proxy = proxies.any? { |proxy| self.class.universe_capable?(proxy, operatingsystem) }
        has_legacy_proxy = proxies.any? { |proxy| !self.class.universe_capable?(proxy, operatingsystem) }
        plans = add_legacy_requests(plans, source) if has_legacy_proxy
        unavailable_sources = unavailable_http_sources(plans, universe: has_universe_proxy, legacy: has_legacy_proxy)

        results = dispatch_requests(proxies, plans)

        {
          operatingsystem_id: operatingsystem.id,
          source: source.description,
          warnings: unavailable_sources.map { |url| _('Boot file not available, download will fail: %{url}') % { url: url } },
          results: results,
        }
      end

      protected

      def resolve_source
        case source_params[:type].to_s
        when 'medium'
          MediumSource.new(operatingsystem, source_params)
        else
          raise InvalidRequest, _('Unsupported boot file source')
        end
      end

      private

      def build_plans(source)
        architectures = source.architectures
        raise InvalidRequest, _('No supported architecture is associated with this operating system') if architectures.empty?

        architectures.map do |architecture|
          [architecture, universe_requests_for(source, architecture)]
        end
      end

      def universe_requests_for(source, architecture)
        prefix = begin
          source.prefix_for(architecture)
        rescue URI::InvalidURIError, ArgumentError => e
          raise InvalidRequest, e.message
        end
        validate_prefix!(prefix)
        requests = begin
          operatingsystem.bootloader_universe_requests(source_prefix: prefix, architecture: architecture)
        rescue Foreman::Exception => e
          # bare_message drops the error code and class prefixes, this is a user-facing error.
          raise InvalidRequest, e.bare_message
        end
        raise InvalidRequest, _('This operating system has no bootloader universe recipe') if requests.empty?

        requests
      end

      def add_legacy_requests(plans, source)
        plans.map do |architecture, universe_requests|
          legacy_requests = operatingsystem.pxe_files(source.legacy_provider_for(architecture)).flat_map do |bootfile|
            bootfile.map { |destination, url| { prefix: destination.to_s, path: url } }
          end
          [architecture, universe_requests, legacy_requests]
        end
      end

      def dispatch_requests(proxies, plans)
        proxies.flat_map do |proxy|
          plans.map do |architecture, universe_requests, legacy_requests|
            dispatch_request(proxy, architecture, universe_requests, legacy_requests)
          end
        end
      end

      def dispatch_request(proxy, architecture, universe_requests, legacy_requests)
        universe = self.class.universe_capable?(proxy, operatingsystem)
        requests = universe ? universe_requests : legacy_requests
        accepted = 0

        begin
          api = ::ProxyAPI::TFTP.new(url: proxy.url)
          requests.each do |request|
            response = universe ? api.fetch_and_process_json(request) : api.fetch_boot_file(request)
            raise Foreman::Exception.new(N_('Smart Proxy rejected a boot file request')) unless response

            accepted += 1
          end
          {
            smart_proxy_id: proxy.id,
            architecture: architecture.name,
            mode: universe ? 'universe' : 'legacy',
            accepted: true,
            request_count: accepted,
          }
        rescue StandardError => e
          {
            smart_proxy_id: proxy.id,
            architecture: architecture.name,
            mode: universe ? 'universe' : 'legacy',
            accepted: false,
            request_count: accepted,
            error: e.message,
          }
        end
      end

      def unavailable_http_sources(plans, universe:, legacy:)
        sources = plans.flat_map do |_architecture, universe_requests, legacy_requests|
          requests = []
          requests.concat(universe_requests) if universe
          requests.concat(legacy_requests || []) if legacy
          requests.map { |request| request.dig(:extract, :source) || request[:source] || request[:path] }
        end
        sources.uniq.reject { |url| http_source_available?(url) }
      end

      # This is advisory: only an HTTP source with an unsuccessful HEAD (or a
      # failed check) produces a warning. The Smart Proxy still gets the fetch.
      def http_source_available?(source)
        uri = URI.parse(source)
        return true unless uri.scheme == 'http'

        redirects_followed = 0
        loop do
          response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', max_retries: 0,
            open_timeout: HTTP_SOURCE_PROBE_TIMEOUT, read_timeout: HTTP_SOURCE_PROBE_TIMEOUT) do |http|
            http.head(uri.request_uri)
          end
          return true if response.is_a?(Net::HTTPSuccess)
          return false unless response.is_a?(Net::HTTPRedirection)
          return false unless response['location'].present?
          return false if redirects_followed >= HTTP_SOURCE_PROBE_MAX_REDIRECTS

          uri = URI.join(uri.to_s, response['location'])
          return false unless HTTP_SCHEMES.include?(uri.scheme) && uri.host.present?

          redirects_followed += 1
        end
      rescue StandardError
        false
      end

      def selected_proxies
        scope = ::SmartProxy.authorized(:view_smart_proxies).with_features('TFTP')
        proxies = if @smart_proxy_ids.nil?
                    scope.to_a.select { |proxy| self.class.universe_capable?(proxy, operatingsystem) }
                  else
                    unless @smart_proxy_ids.is_a?(Array) && @smart_proxy_ids.any?
                      raise InvalidRequest, _('Select at least one TFTP Smart Proxy')
                    end
                    ids = @smart_proxy_ids.map { |id| Integer(id) }.uniq
                    selected = scope.where(id: ids).to_a
                    raise InvalidRequest, _('A selected TFTP Smart Proxy was not found or is not visible') unless selected.size == ids.size

                    selected
                  end
        raise InvalidRequest, _('No compatible TFTP Smart Proxy is available') if proxies.empty?

        proxies
      rescue ArgumentError, TypeError
        raise InvalidRequest, _('Smart Proxy IDs must be integers')
      end

      def validate_prefix!(prefix)
        uri = URI.parse(prefix)
        unless %w[http https ftp].include?(uri.scheme) && uri.host.present? && uri.query.nil? && uri.fragment.nil?
          raise InvalidRequest, _('Boot file source must be an HTTP, HTTPS, or FTP URL prefix')
        end
      rescue URI::InvalidURIError
        raise InvalidRequest, _('Boot file source URL is invalid')
      end
    end
  end
end
