class ChangeOidcAudienceSettingType < ActiveRecord::Migration[5.2]
  def up
    setting = Setting.find_by :name => 'oidc_audience'
    return unless setting
    setting.value = [setting.value] if setting.value.is_a?(String)
    setting.settings_type = 'array'
    setting.default = []
    setting.save
  end

  def down
    setting = Setting.find_by :name => 'oidc_audience'
    return unless setting
    setting.value = setting.value.first if setting.value.is_a?(Array)
    setting.settings_type = 'string'
    setting.default = nil
    setting.save
  end
end
