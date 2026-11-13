require 'digest'
require 'uri'

module Foreman
  module BootloaderUniverse
    class HostBootFiles
      class NotReady < StandardError; end

      def initialize(host)
        @host = host
      end

      def call
        return unless @host.build?

        details = plan_details
        return unless details

        boot_files = details[:boot_files]

        ready_params = {
          targetos: @host.operatingsystem.name.downcase, release: @host.operatingsystem.release, arch: @host.arch.name,
          universe_kernel: boot_files[:kernel], universe_initrd: boot_files[:initrd]
        }
        details[:proxies].each do |proxy|
          begin
            next if ::ProxyAPI::TFTP.new(url: proxy.url).universe_boot_files_ready?(ready_params)
          rescue ::ProxyAPI::ProxyException => e
            raise NotReady, _("Unable to check boot files for %{os} on %{proxy}: %{error}") %
              { os: @host.operatingsystem.fullname, proxy: proxy.url, error: e.message }
          end
          raise NotReady, _("Boot files for %{os} are not ready on %{proxy}. Sync boot files or wait for the download to finish, then retry") %
            { os: @host.operatingsystem.fullname, proxy: proxy.url }
        end

        if details[:iso]
          boot_files[:installation_iso] = httpboot_iso_url(@host.provision_interface, @host.operatingsystem, details[:iso], ready_params) || details[:iso][:source]
        end

        boot_files
      end

      # Build the prospective files without requiring build mode or querying their readiness.
      def plan
        plan_details&.fetch(:boot_files)
      end

      private

      def plan_details
        return unless @host.pxe_loader.present? && @host.pxe_loader_efi?
        return if Foreman::Cast.to_bool(@host.host_param('disable_universe')) == true

        os = @host.operatingsystem
        architecture = @host.arch
        return unless os && architecture
        # Only Grub2 is currently supported for bootloader universe
        return unless os.pxe_loader_kind(@host) == :PXEGrub2

        interface = @host.provision_interface
        return unless interface && (interface.tftp? || interface.tftp6?)

        proxies = []
        proxies << interface.subnet.tftp if interface.tftp?
        proxies << interface.subnet6.tftp if interface.tftp6?
        proxies = proxies.compact.uniq(&:url)
        return if proxies.empty?
        return unless proxies.all? do |proxy|
          Download.universe_capable?(proxy, os) && proxy.has_capability?(:TFTP, :bootloader_universe_boot_files)
        end

        boot_files = os.bootloader_universe_boot_files(architecture)
        return unless boot_files

        provider = @host.medium_provider
        return unless provider

        prefix = provider.boot_file_source_uri(operatingsystem: os, architecture: architecture).to_s
        uri = URI.parse(prefix)
        return unless %w[http https ftp].include?(uri.scheme) && uri.host && !uri.query && !uri.fragment

        requests = os.bootloader_universe_requests(source_prefix: prefix, architecture: architecture)
        extraction = requests.filter_map { |request| request[:extract] }.find do |request|
          boot_files.values.all? { |path| request[:files].key?(path) }
        end
        return unless extraction

        plan = {
          kernel: boot_files[:kernel],
          initrd: boot_files[:initrd],
          archive: extraction[:destination],
          source_digest: Digest::SHA256.hexdigest(extraction[:source]),
        }
        # Ubuntu's live installer needs the ISO as well as its kernel/initrd.
        iso = requests.find { |request| request[:destination] == "#{os.bootloader_universe_directory(architecture)}/boot.iso" }
        plan[:installation_iso] = iso[:source] if iso

        { boot_files: plan, proxies: proxies, iso: iso }
      rescue URI::InvalidURIError
        nil
      end

      def httpboot_iso_url(interface, os, iso, ready_params)
        proxy = (interface.subnet.httpboot if interface.tftp?) || (interface.subnet6.httpboot if interface.tftp6?)
        return unless proxy

        http_port = proxy.httpboot_http_port
        https_port = proxy.httpboot_https_port
        return unless http_port || https_port

        scheme = http_port ? URI::HTTP : URI::HTTPS
        url = scheme.build(host: proxy.hostname, port: http_port || https_port,
          path: "/httpboot/#{iso[:destination]}").to_s
        api = ::ProxyAPI::TFTP.new(url: proxy.url)
        ready_check = Download.universe_capable?(proxy, os) && proxy.has_capability?(:TFTP, :bootloader_universe_boot_files)
        return if ready_check && !api.universe_boot_files_ready?(ready_params)
        return unless api.httpboot_file_ready?(url)

        url
      rescue ::ProxyAPI::ProxyException, URI::Error
        nil
      end
    end
  end
end
