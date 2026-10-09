class Debian < Operatingsystem
  PXEFILES = {:kernel => "linux", :initrd => "initrd.gz"}

  def bootloader_universe_boot_files(architecture)
    return nil unless architecture.name == 'x86_64'

    directory = bootloader_universe_directory(architecture)
    { kernel: "#{directory}/linux", initrd: "#{directory}/initrd.gz" }
  end

  def bootloader_source_architecture(architecture)
    architecture.name == 'x86_64' ? 'amd64' : architecture.name
  end

  def bootloader_universe_requests(source_prefix:, architecture:)
    return [] unless architecture.name == 'x86_64'

    directory = bootloader_universe_directory(architecture)
    boot_files = bootloader_universe_boot_files(architecture)
    grub = "#{directory}/grubx64.efi"

    if guess_os == 'ubuntu'
      ubuntu_bootloader_requests(source_prefix, directory, grub, boot_files)
    else
      debian_bootloader_requests(source_prefix, directory, grub, boot_files)
    end
  end

  def pxedir(medium_provider = nil)
    if is_subiquity? # support Ubuntu 22.04, which drops legacy_image support
      'casper'
    elsif (guess_os == 'ubuntu' && major.to_i >= 20) # support ubuntu focal(20), which moved pxe files to legacy_image
      'dists/$release/main/installer-$arch/current/legacy-images/netboot/' + guess_os + '-installer/$arch'
    else
      'dists/$release/main/installer-$arch/current/images/netboot/' + guess_os + '-installer/$arch'
    end
  end

  def preseed_server(medium_provider)
    medium_provider.medium_uri.select(:host, :port).compact.join(':')
  end

  def preseed_path(medium_provider)
    medium_provider.medium_uri(&method(:transform_vars)).select(:path, :query).compact.join('?')
  end

  def boot_file_sources(medium_provider, &block)
    super do |vars|
      vars = yield(vars) if block_given?

      transform_vars(vars)
    end
  end

  def available_loaders
    self.class.all_loaders
  end

  def pxe_type
    "preseed"
  end

  # debian-installer receives the provisioning token on the kernel command line,
  # so the unattended endpoint can require it for these hosts.
  def token_enforced?
    true
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    true
  end

  # Helper text shown next to release name (do not use i18n)
  def release_name_help
    'bullseye, focal, buster, bionic, stretch, xenial...'
  end

  def display_family
    "Debian"
  end

  def shorten_description(description)
    return "" if description.blank?
    s = description.dup
    s.gsub!('GNU/Linux', '')
    s.gsub!(/\(.+?\)/, '')
    s.squeeze! " "
    s.strip!
    s += '.' + minor unless minor.blank? || s.include?('.')
    s.presence || description
  end

  def pxe_file_names(medium_provider)
    if is_subiquity?
      {
        kernel: 'vmlinuz',
        initrd: 'initrd',
      }
    else
      super
    end
  end

  private

  def debian_bootloader_requests(source_prefix, directory, grub, boot_files)
    shim = "#{directory}/shimx64.efi"
    archive = "dists/#{release_name}/main/installer-amd64/current/images/netboot/netboot.tar.gz"
    [{
      extract: {
        source: bootloader_source_url(source_prefix, archive),
        destination: "#{directory}/netboot.tar.gz",
        type: 'tgz',
        files: {
          boot_files[:kernel] => 'debian-installer/amd64/linux',
          boot_files[:initrd] => 'debian-installer/amd64/initrd.gz',
          grub => 'debian-installer/amd64/grubx64.efi',
          shim => 'debian-installer/amd64/bootnetx64.efi',
        },
        symlinks: {
          "#{directory}/boot.efi" => grub,
          "#{directory}/boot-sb.efi" => shim,
        },
      },
    }]
  end

  def ubuntu_bootloader_requests(source_prefix, directory, grub, boot_files)
    shim = "#{directory}/shimx64.efi"
    version = release
    [{
      extract: {
        source: bootloader_source_url(source_prefix, "#{version}/ubuntu-#{version}-netboot-amd64.tar.gz"),
        destination: "#{directory}/netboot.tar.gz",
        type: 'tgz',
        files: {
          boot_files[:kernel] => 'amd64/linux',
          boot_files[:initrd] => 'amd64/initrd',
          grub => 'amd64/grubx64.efi',
          shim => 'amd64/bootx64.efi',
        },
        symlinks: {
          "#{directory}/boot.efi" => grub,
          "#{directory}/boot-sb.efi" => shim,
        },
      },
    }, {
      source: bootloader_source_url(source_prefix, "#{version}/ubuntu-#{version}-live-server-amd64.iso"),
      destination: "#{directory}/boot.iso",
    }]
  end

  # tries to guess if this an ubuntu or a debian os
  def guess_os
    (name =~ /ubuntu/i) ? "ubuntu" : "debian"
  end

  def is_subiquity?
    return false if guess_os != "ubuntu"
    return false if major.to_i < 20
    return false if major.to_i == 20 && minor.present? && minor.to_i <= 2
    true # Ubuntu release 20.04.3 or newer
  end

  def transform_vars(vars)
    vars[:arch] = vars[:arch].sub('x86_64', 'amd64')
    vars[:arch] = vars[:arch].sub('aarch64', 'arm64')
  end
end
