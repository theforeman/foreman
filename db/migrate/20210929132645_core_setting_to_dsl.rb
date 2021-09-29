class CoreSettingToDsl < ActiveRecord::Migration[6.0]
  def up
    Setting.where(category: %w[Setting::Auth]).update_all(category: 'Setting')
  end
end
