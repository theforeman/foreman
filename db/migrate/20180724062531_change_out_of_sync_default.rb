class ChangeOutOfSyncDefault < ActiveRecord::Migration[5.1]
  def up
    return unless outofsync_setting
    outofsync_setting.update_attribute(:default, 30)
    outofsync_setting.update_attribute(:value, 30) if outofsync_setting.value == 5
  end

  def down
    return unless outofsync_setting
    outofsync_setting.update_attribute(:default, 5)
  end

  private

  def outofsync_setting
    @setting ||= Setting.where(:name => 'outofsync_interval').first
  end
end
