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
    value = Setting.where(name: 'update_subnets_from_facts').pick(:value)
    return unless value
    if value == 'none'
      new_value = false
    else
      new_value = true
    end
    Setting.where(name: 'update_subnets_from_facts').update_all(value: new_value)
  end
end
