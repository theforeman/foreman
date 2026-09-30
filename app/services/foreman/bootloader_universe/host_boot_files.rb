require 'digest'
require 'uri'

module Foreman
  module BootloaderUniverse
    class HostBootFiles
      def initialize(host)
        @host = host
      end

      def call
        return unless @host.build? && @host.pxe_loader.present? && @host.pxe_loader_efi?
        return if Foreman::Cast.to_bool(@host.host_param('disable_universe')) == true

        os = @host.operatingsystem
        architecture = @host.arch
        return unless os && architecture
        # Only Grub2 is currently supported for bootloader universe
        return unless os.pxe_loader_kind(@host) == :PXEGrub2

        boot_files = os.bootloader_universe_boot_files(architecture)
        return unless boot_files

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
        # Use the recipe's URL, including BootPath and its original scheme;
        # a TFTP proxy does not necessarily provide an HTTP server for its copy.
        iso = requests.find { |request| request[:destination] == "#{os.bootloader_universe_directory(architecture)}/boot.iso" }
        plan[:installation_iso] = iso[:source] if iso
        plan
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
