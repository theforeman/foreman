module SettingsHelper
  def short_cat(category)
    category.gsub(/Setting::/, '')
  end

  def cat_label(category)
    category.constantize.humanized_category || short_cat(category)
  end

  def grouped_settings(settings)
    settings.each_with_object({}) do |setting, memo|
      hash = setting_to_hash(setting)
      if memo[setting.category]
        memo[setting.category] << hash
      else
        memo[setting.category] = [hash]
      end
      memo
    end
  end

  def setting_to_hash(setting)
    presenter = SettingPresenter.from_setting(setting)
    {
      :id => setting.id,
      :name => presenter.name,
      :category => presenter.category,
      :description => presenter.description,
      :settings_type => presenter.settings_type,
      :default => presenter.default,
      :readonly => presenter.readonly?,
      :full_name => presenter.full_name,
      :config_file => presenter.config_file,
      :select_values => presenter.select_values,
      :value => presenter.safe_value,
      :encrypted => presenter.encrypted?,
    }
  end
end
