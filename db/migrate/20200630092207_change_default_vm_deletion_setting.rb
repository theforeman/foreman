class ChangeDefaultVmDeletionSetting < ActiveRecord::Migration[6.0]
  def up
    Setting.without_auditing do
      setting = Setting.where(:name => 'destroy_vm_on_host_delete').first
      setting&.update_attribute(:default, false)
    end
  end

  def down
    Setting.without_auditing do
      setting = Setting.where(:name => 'destroy_vm_on_host_delete').first
      setting&.update_attribute(:default, true)
    end
  end
end
