class GeneralSettingToDsl < ActiveRecord::Migration[6.0]
  def up
    Setting.where(category: 'Setting::General').update_all(category: 'Setting')
  end
end
