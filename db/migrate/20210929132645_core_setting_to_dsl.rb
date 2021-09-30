class CoreSettingToDsl < ActiveRecord::Migration[6.0]
  def up
    Setting.where(category: %w[Setting::Auth Setting::Email Setting::Notification Setting::Provisioning]).update_all(category: 'Setting')
  end
end
