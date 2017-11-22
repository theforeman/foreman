class MakeTemplatesDefault < ActiveRecord::Migration[4.2]
  class FakeConfigTemplate < ApplicationRecord
    self.table_name = 'config_templates'
  end

  def up
    update_templates_default_to true
  end

  def down
    update_templates_default_to false
  end

  private

  def update_templates_default_to(flag)
    templates = ["PXELinux global default", "PXELinux default local boot", "PXELinux default memdisk",
                 "PXEGrub default local boot", "Alterator default", "Alterator default finish",
                 "Alterator default PXELinux", "AutoYaST default",  "AutoYaST SLES default",
                 "AutoYaST default PXELinux", "FreeBSD (mfsBSD) finish", "FreeBSD (mfsBSD) provision",
                 "FreeBSD (mfsBSD) PXELinux", "Grubby default", "Jumpstart default",
                 "Jumpstart default finish", "Jumpstart default PXEGrub", "Kickstart default",
                 "Kickstart RHEL default", "Kickstart default finish", "Kickstart default PXELinux",
                 "Kickstart default iPXE", "Kickstart default user data", "Preseed default",
                 "Preseed default finish", "Preseed default PXELinux", "Preseed default iPXE",
                 "Preseed default user data", "UserData default", "WAIK default PXELinux",
                 "Junos default SLAX", "Junos default ZTP config"]

    templates.each do |template|
      if (template = FakeConfigTemplate.find_by_name(template))
        template.update_attribute(:default, flag)
      end
    end
  end
end
