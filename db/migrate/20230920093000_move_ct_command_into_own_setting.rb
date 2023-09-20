class MoveCtCommandIntoOwnSetting < ActiveRecord::Migration[6.1]
  def up
    ['ct', 'fcct'].each do |setting_prefix|
      setting = Setting.find_by(name: "#{setting_prefix}_command")
      if setting
        new_setting = setting.dup
        new_setting.value = setting.value.drop(1)
        new_setting.name = "#{setting_prefix}_arguments"
        new_setting.save
        setting.delete
      end
    end
  end

  def down
    ['ct', 'fcct'].each do |setting_prefix|
      setting = Setting.find_by(name: "#{setting_prefix}_arguments")
      if setting
        new_setting = setting.dup
        new_setting.value = ["/usr/bin/#{setting_prefix}"] + setting.value
        new_setting.name = "#{setting_prefix}_command"
        new_setting.save
        setting.delete
      end
    end
  end
end
