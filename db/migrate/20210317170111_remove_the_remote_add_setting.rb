class RemoveTheRemoteAddSetting < ActiveRecord::Migration[6.0]
  def up
    Setting.where(name: 'remote_addr').delete_all
  end

  def down
    # no action, seeding on app start will create the object with the correct default value
  end
end
