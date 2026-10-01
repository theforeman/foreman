require 'ostruct'
require 'net/http'
require 'uri'

module Foreman
  module BootloaderUniverse
    class Download
      class InvalidRequest < StandardError; end

      class MediumSource
        attr_reader :medium

        def initialize(operatingsystem, source)
          @operatingsystem = operatingsystem
          @medium = ::Medium.authorized(:view_media).find_by(id: source[:id])
          raise InvalidRequest, N_('Installation medium was not found or is not visible') unless @medium
          unless @operatingsystem.media.exists?(@medium.id)
            raise InvalidRequest, N_('Installation medium is not associated with this operating system')
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
        return false unless proxy.has_capability?(:TFTP, :bootloader_archive_iso)

        return true if operatingsystem.is_a?(::Redhat)

        operatingsystem.is_a?(::Debian) && proxy.has_capability?(:TFTP, :bootloader_archive_tgz)
      end

      def call
        source = resolve_source
        architectures = source.architectures
        raise InvalidRequest, N_('No supported architecture is associated with this operating system') if architectures.empty?

        plans = architectures.map do |architecture|
          prefix = begin
            source.prefix_for(architecture)
          rescue URI::InvalidURIError, ArgumentError => e
            raise InvalidRequest, e.message
          end
          validate_prefix!(prefix)
          universe_requests = begin
            operatingsystem.bootloader_universe_requests(source_prefix: prefix, architecture: architecture)
          rescue Foreman::Exception => e
            raise InvalidRequest, e.message
          end
          raise InvalidRequest, N_('This operating system has no bootloader universe recipe') if universe_requests.empty?

          [architecture, universe_requests]
        end

        proxies = selected_proxies
        unavailable_sources = if proxies.any? { |proxy| self.class.universe_capable?(proxy, operatingsystem) }
                                unavailable_http_sources(plans)
                              else
                                []
                              end
        if proxies.any? { |proxy| !self.class.universe_capable?(proxy, operatingsystem) }
          plans.map! do |architecture, universe_requests|
            legacy_requests = operatingsystem.pxe_files(source.legacy_provider_for(architecture)).flat_map do |bootfile|
              bootfile.map { |destination, url| { prefix: destination.to_s, path: url } }
            end
            [architecture, universe_requests, legacy_requests]
          end
        end

        results = proxies.flat_map do |proxy|
          plans.map do |architecture, universe_requests, legacy_requests|
            universe = self.class.universe_capable?(proxy, operatingsystem)
            requests = universe ? universe_requests : legacy_requests
            accepted = 0

            begin
              api = ::ProxyAPI::TFTP.new(url: proxy.url)
              requests.each do |request|
                response = universe ? api.fetch_boot_file_json(request) : api.fetch_boot_file(request)
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
        end

        {
          operatingsystem_id: operatingsystem.id,
          source: source.description,
          warnings: unavailable_sources.map { |url| N_('Boot file not available, download will fail: %{url}') % { url: url } },
          results: results,
        }
      end

      protected

      def resolve_source
        case source_params[:type].to_s
        when 'medium'
          MediumSource.new(operatingsystem, source_params)
        else
          raise InvalidRequest, N_('Unsupported boot file source')
        end
      end

      private

      def unavailable_http_sources(plans)
        plans.flat_map { |_architecture, requests| requests.map { |request| request.dig(:extract, :source) || request[:source] } }
             .uniq.reject { |url| http_source_available?(url) }
      end

      # This is advisory: only an HTTP source with an unsuccessful HEAD (or a
      # failed check) produces a warning. The Smart Proxy still gets the fetch.
      def http_source_available?(source)
        uri = URI.parse(source)
        return true unless uri.scheme == 'http'

        5.times do
          response = Net::HTTP.start(uri.host, uri.port, open_timeout: 3, read_timeout: 3) do |http|
            http.head(uri.request_uri)
          end
          return true if response.is_a?(Net::HTTPSuccess)
          return false unless response.is_a?(Net::HTTPRedirection) && response['location'].present?

          uri = URI.join(uri.to_s, response['location'])
          return true unless uri.scheme == 'http'
        end
        false
      rescue StandardError
        false
      end

      def selected_proxies
        scope = ::SmartProxy.authorized(:view_smart_proxies).with_features('TFTP')
        proxies = if @smart_proxy_ids.nil?
                    scope.to_a.select { |proxy| self.class.universe_capable?(proxy, operatingsystem) }
                  else
                    unless @smart_proxy_ids.is_a?(Array) && @smart_proxy_ids.any?
                      raise InvalidRequest, N_('Select at least one TFTP Smart Proxy')
                    end
                    ids = @smart_proxy_ids.map { |id| Integer(id) }.uniq
                    selected = scope.where(id: ids).to_a
                    raise InvalidRequest, N_('A selected TFTP Smart Proxy was not found or is not visible') unless selected.size == ids.size

                    selected
                  end
        raise InvalidRequest, N_('No compatible TFTP Smart Proxy is available') if proxies.empty?

        proxies
      rescue ArgumentError, TypeError
        raise InvalidRequest, N_('Smart Proxy IDs must be integers')
      end

      def validate_prefix!(prefix)
        uri = URI.parse(prefix)
        unless %w[http https ftp].include?(uri.scheme) && uri.host.present? && uri.query.nil? && uri.fragment.nil?
          raise InvalidRequest, N_('Boot file source must be an HTTP, HTTPS, or FTP URL prefix')
        end
      rescue URI::InvalidURIError
        raise InvalidRequest, N_('Boot file source URL is invalid')
      end
    end
  end
end
