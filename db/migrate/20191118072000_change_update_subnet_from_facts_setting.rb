class ChangeUpdateSubnetFromFactsSetting < ActiveRecord::Migration[5.2]
  def up
    setting = Setting.find_by :name => 'update_subnets_from_facts'
    return unless setting
    if setting.value
      setting.value = 'all'
    else
      setting.value = 'none'
    end
    setting.settings_type = 'string'
    setting.default = 'none'
    setting.save
  end

  def down
    setting = Setting.find_by :name => 'update_subnets_from_facts'
    return unless setting
    if setting.value == 'none'
      setting.value = false
    else
      setting.value = true
    end
    setting.settings_type = 'boolean'
    setting.default = false
    setting.save
  end
end
