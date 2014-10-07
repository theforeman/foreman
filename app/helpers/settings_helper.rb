module SettingsHelper

  def value(setting)
    if setting.readonly?
      return readonly_field(
          setting, :value,
          {:title => _("This setting is defined in the configuration file 'settings.yaml' and is read-only."), :helper => :show_value})
    end

    case setting.settings_type
    when "boolean"
      edit_select(setting, :value, {:select_values => {:true => "true", :false => "false"}.to_json } )
    else
      edit_textfield(setting, :value,{:helper => :show_value})
    end
  end

  def show_value(setting)
    case setting.settings_type
    when "array"
      "[ " + setting.value.join(", ") + " ]"
    else
      setting.value
    end
  rescue
    setting.value
  end

  def short_cat(category)
    category.gsub(/Setting::/,'')
  end

end
