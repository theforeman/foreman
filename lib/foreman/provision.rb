module Foreman::Provision
  PXE_TEMPLATE_KINDS = ["PXEGrub2", "PXELinux", "PXEGrub", "iPXE"]

  def self.local_boot_default_name(kind)
    "#{kind} default local boot"
  end

  def self.global_default_name(kind)
    "#{kind} global default"
  end

  autoload :SSH, 'foreman/provision/ssh'
end
