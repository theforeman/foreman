module SettingsHelper
  def grouped_settings(settings)
    can_edit = User.current.can?(:edit_settings)
    settings.map { |s| setting_to_hash(s, can_edit: can_edit) }.group_by { |s| s[:category] }
  end

  def setting_to_hash(setting, can_edit: User.current.can?(:edit_settings))
    {
      :id => setting.id,
      :name => setting.name,
      :category => setting.category_name,
      :description => setting.description,
      :settings_type => setting.settings_type,
      :default => setting.default,
      :readonly => setting.readonly? || !can_edit,
      :full_name => setting.full_name,
      :select_values => setting.select_values,
      :value => setting.safe_value,
      :encrypted => setting.encrypted?,
    }
  end
end
