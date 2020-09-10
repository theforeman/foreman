class AdjustPuppetOutOfSyncInterval < ActiveRecord::Migration[5.1]
  def up
    return unless puppet_outofsync_setting
    puppet_outofsync_setting.update_attribute(:default, 35)
    puppet_outofsync_setting.update_attribute(:value, 35) if puppet_outofsync_setting.value == 30
  end

  def down
    return unless puppet_outofsync_setting
    puppet_outofsync_setting.update_attribute(:default, 30)
  end

  private

  def puppet_outofsync_setting
    @setting ||= Setting.where(:name => 'puppet_interval').first
  end
end
