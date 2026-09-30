class Redhat < Operatingsystem
  PXEFILES = {:kernel => "vmlinuz", :initrd => "initrd.img"}

  def bootloader_universe_boot_files(architecture)
    return nil unless architecture.name == 'x86_64'

    directory = bootloader_universe_directory(architecture)
    { kernel: "#{directory}/vmlinuz", initrd: "#{directory}/initrd.img" }
  end

  def bootloader_universe_requests(source_prefix:, architecture:)
    return [] unless architecture.name == 'x86_64'

    directory = bootloader_universe_directory(architecture)
    boot_files = bootloader_universe_boot_files(architecture)
    grub = "#{directory}/grubx64.efi"
    shim = "#{directory}/shimx64.efi"
    [{
      extract: {
        source: bootloader_source_url(source_prefix, 'images/boot.iso'),
        destination: "#{directory}/boot.iso",
        type: 'iso',
        files: {
          grub => 'EFI/BOOT/grubx64.efi',
          shim => 'EFI/BOOT/BOOTX64.EFI',
          boot_files[:kernel] => 'images/pxeboot/vmlinuz',
          boot_files[:initrd] => 'images/pxeboot/initrd.img',
        },
        symlinks: {
          "#{directory}/boot.efi" => grub,
          "#{directory}/boot-sb.efi" => shim,
        },
      },
    }]
  end

  # outputs kickstart installation medium based on the medium type (NFS or URL)
  # it also convert the $arch string to the current host architecture
  def mediumpath(medium_provider)
    uri = medium_provider.medium_uri

    case uri.scheme
      when 'http', 'https', 'ftp'
        "url --url #{uri}"
      else
        server = uri.select(:host, :port).compact.join(':')
        dir    = uri.select(:path, :query).compact.join('?')
        "nfs --server #{server} --dir #{dir}"
    end
  end

  def available_loaders
    self.class.all_loaders
  end

  # The PXE type to use when generating actions and evaluating attributes. jumpstart, kickstart and preseed are currently supported.
  def pxe_type
    "kickstart"
  end

  def pxe_file_names(medium_provider)
    if medium_provider&.architecture_name&.match?(/^[Ss]390/)
      {
        kernel: "kernel.img",
        initrd: "initrd.img",
      }
    else
      super
    end
  end

  def pxedir(medium_provider = nil)
    case medium_provider.try(:architecture_name)
    when /^ppc64/i
      "ppc/ppc64"
    when /^s390/i
      "images"
    else
      "images/pxeboot"
    end
  end

  def display_family
    "Red Hat"
  end

  def shorten_description(description)
    return "" if description.blank?
    s = description.dup
    s.gsub!('Red Hat Enterprise Linux', 'RHEL')
    s.gsub!('release', '')
    s.gsub!(/\(.+?\)/, '')
    s.squeeze! " "
    s.strip!
    s.presence || description
  end

  def pxe_kernel_options(params)
    options = super
    options << "modprobe.blacklist=#{params['blacklist'].delete(' ')}" if params['blacklist']
    options
  end

  # Helper text shown next to minor version (do not use i18n)
  def minor_version_help
    '0, 6.1810'
  end
end
