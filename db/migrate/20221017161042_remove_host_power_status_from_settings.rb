class RemoveHostPowerStatusFromSettings < ActiveRecord::Migration[6.1]
  def up
    Setting.where(name: 'host_power_status').delete_all
  end

  def down
    # no action, seeding on app start should create the object with the default value
  end
end
