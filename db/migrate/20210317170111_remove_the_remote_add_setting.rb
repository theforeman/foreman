class RemoveTheRemoteAddSetting < ActiveRecord::Migration[6.0]
  def up
    Setting.find_by_name('remote_addr').try(:destroy)
  end

  def down
    # no action, seeding on app start will create the object with the correct default value
  end
end
