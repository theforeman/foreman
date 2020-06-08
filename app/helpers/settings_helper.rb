module SettingsHelper
  def value(setting)
    if setting.readonly?
      return readonly_field(setting, :value,
        {:title => _("This setting is defined in the configuration file '%{filename}' and is read-only.") % {:filename => setting.class.config_file}, :helper => :show_value})
    end

    select_collection = Setting.select_collection_registry.collection_for setting

    unless select_collection.empty?
      return edit_select(setting, :value,
        {:title => setting.full_name_with_default, :select_values => select_collection })
    end

    placeholder = setting.has_default? ? setting.default : "No default value was set"
    return edit_textarea(setting, :value, {:title => setting.full_name_with_default, :helper => :show_value, :placeholder => placeholder}) if setting.settings_type == 'array'
    edit_textfield(setting, :value, {:title => setting.full_name_with_default, :helper => :show_value, :placeholder => placeholder})
  end

  def show_value(setting)
    case setting.settings_type
    when "array"
      "[ " + setting.value.join(", ") + " ]"
    else
      setting.safe_value
    end
  rescue
    setting.value
  end

  def short_cat(category)
    category.gsub(/Setting::/, '')
  end

  def cat_label(category)
    category.constantize.humanized_category || short_cat(category)
  end

  def translate_full_name(setting)
    fullname = setting.full_name.nil? ? setting.name : _(setting.full_name)
    trunc_with_tooltip(fullname, 32, setting.name, false)
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
    {
      :id => setting.id,
      :name => setting.name,
      :category => setting.category,
      :description => setting.description,
      :settings_type => setting.settings_type,
      :default => setting.default,
      :readonly => setting.readonly?,
      :full_name => setting.full_name,
      :config_file => setting.class.config_file,
      :select_values => setting.select_collection,
      :value => setting.value,
    }
  end
end
