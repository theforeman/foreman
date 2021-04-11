module SettingsHelper
  def grouped_settings(settings)
    settings.map { |s| setting_to_hash(s) }.group_by { |s| s[:category] }
  end

  def setting_to_hash(setting)
    {
      :id => setting.id,
      :name => setting.name,
      :category => setting.category_name,
      :description => setting.description,
      :settings_type => setting.settings_type,
      :default => setting.default,
      :readonly => setting.readonly?,
      :full_name => setting.full_name,
      :config_file => setting.config_file,
      :select_values => setting.select_values,
      :value => setting.safe_value,
      :encrypted => setting.encrypted?,
    }
  end
end
