class ChangeUpdateSubnetFromFactsSetting < ActiveRecord::Migration[5.2]
  def up
    setting = Setting.where(name: 'update_subnets_from_facts')
    return unless setting.exists?
    if setting.pick(:value)
      new_value = 'all'
    else
      new_value = 'none'
    end
    setting.update_all(value: new_value)
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
