class RenameSeededTemplates < ActiveRecord::Migration[4.2]
  CONFIG_RENAMES = {
    "Grubby Default" => "Grubby default",
    "Jumpstart Default" => "Jumpstart default",
    "Jumpstart default PXEGrub" => "Jumpstart default PXEGrub",
    "Jumstart Default Finish" => "Jumpstart default finish",
    "Kickstart Default" => "Kickstart default",
    "Kickstart default PXElinux" => "Kickstart default PXELinux",
    "Kickstart default gPXE" => "Kickstart default iPXE",
    "PXE Default File" => "PXELinux global default",
    "PXE Localboot Default" => "PXELinux default local boot",
    "PXEGrub Localboot Default" => "PXEGrub default local boot",
    "Preseed Default" => "Preseed default",
    "Preseed Default Finish" => "Preseed default finish",
    "Preseed default PXElinux" => "Preseed default PXELinux",
    "RHEL Kickstart Default" => "Kickstart RHEL default",
    "YaST2 Default" => "AutoYaST default",
    "YaST2 default PXELinux" => "AutoYaST default PXELinux",
    "Waik default PXELinux" => "WAIK default PXELinux",
  }

  PTABLE_RENAMES = {
    "RedHat default" => "Kickstart default",
    "Ubuntu default" => "Preseed default",
    "Ubuntu custom LVM" => "Preseed custom LVM",
    "Solaris medium disk mirrored" => "Jumpstart mirrored",
    "Solaris small disk c0t0" => "Jumpstart default",
    "SuSE Entire SCSI Disk" => "AutoYaST entire SCSI disk",
    "SuSE Entire Virtual Disk" => "AutoYaST entire virtual disk",
  }

  MEDIA_RENAMES = {
    "Fedora Mirror" => "Fedora mirror",
    "OpenSuSE Mirror" => "OpenSUSE mirror",
    "Ubuntu Mirror" => "Ubuntu mirror",
  }

  class FakeConfigTemplate < ApplicationRecord
    self.table_name = 'config_templates'
  end

  class FakePtable < ApplicationRecord
    self.table_name = 'ptables'
  end

  def up
    CONFIG_RENAMES.each do |old, new|
      FakeConfigTemplate.find_by_name(old).try(:update_attributes, :name => new)
    end
    PTABLE_RENAMES.each do |old, new|
      FakePtable.find_by_name(old).try(:update_attributes, :name => new)
    end
    MEDIA_RENAMES.each do |old, new|
      Medium.find_by_name(old).try(:update_attributes, :name => new)
    end
    TemplateKind.find_by_name('gPXE').try(:update_attributes, :name => 'iPXE')
  end

  def down
    CONFIG_RENAMES.each do |old, new|
      FakeConfigTemplate.find_by_name(new).try(:update_attributes, :name => old)
    end
    PTABLE_RENAMES.each do |old, new|
      FakePtable.find_by_name(new).try(:update_attributes, :name => old)
    end
    MEDIA_RENAMES.each do |old, new|
      Medium.find_by_name(new).try(:update_attributes, :name => old)
    end
    TemplateKind.find_by_name('iPXE').try(:update_attributes, :name => 'gPXE')
  end
end
