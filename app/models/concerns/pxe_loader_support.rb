module PxeLoaderSupport
  extend ActiveSupport::Concern

  PXE_KINDS = {
    :PXELinux => /^(pxelinux|PXELinux).*/,
    :PXEGrub => /^(grub\/|Grub ).*/,
    :PXEGrub2 => /^(grub2|Grub2).*/
  }.with_indifferent_access.freeze

  # preference order is defined in Operatingsystem#template_kinds
  PREFERRED_KINDS = {
    :PXELinux => "PXELinux BIOS",
    :PXEGrub2 => "Grub2 UEFI",
    :PXEGrub => "Grub UEFI"
  }.with_indifferent_access.freeze

  class_methods do
    def all_loaders_map(precision = 'x64')
      {
        "None" => "",
        "PXELinux BIOS" => "pxelinux.0",
        "PXELinux UEFI" => "pxelinux.efi",
        "Grub UEFI" => "grub/grub#{precision}.efi",
        "Grub2 UEFI" => "grub2/grub#{precision}.efi",
        "Grub2 UEFI SecureBoot" => "grub2/shim#{precision}.efi"
      }.freeze
    end

    def all_loaders
      all_loaders_map.keys.freeze
    end

    def valid_loader_name?(pxe_loader)
      self.all_loaders.include?(pxe_loader)
    end

    def firmware_type(pxe_loader)
      case pxe_loader
      when 'None'
        :none
      when /UEFI/
        :uefi
      else
        :bios
      end
    end
  end

  def default_boot_filename
    "pxelinux.0"
  end

  # Finds template kind for given loader filename or name or nil for "None" or ""
  def pxe_loader_kind(host)
    PXE_KINDS.find{|k, v| v.match(host.pxe_loader)}.try(:first).try(:to_sym)
  end

  # Suggested PXE loader when template kind is available (PXEGrub2, then PXELinux, then PXEGrub in this order)
  def preferred_loader
    associated_templates = os_default_templates.map(&:template_kind).compact.map(&:name)
    template_kinds.each do |loader|
      return PREFERRED_KINDS[loader] if associated_templates.include? loader
    end
    nil
  end
end
