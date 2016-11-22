module SettingsHelper
  def value(setting)
    return readonly_field(setting, :value,
      {:title => _("This setting is defined in the configuration file 'settings.yaml' and is read-only."), :helper => :show_value}) if setting.readonly?

    return edit_select(setting, :value,
      {:title => _(setting.full_name), :select_values => self.send("#{setting.name}_collection") }) if self.respond_to? "#{setting.name}_collection"

    return edit_textarea(setting, :value, {:title => _(setting.full_name), :helper => :show_value}) if setting.settings_type == 'array'
    edit_textfield(setting, :value,{:title => _(setting.full_name), :helper => :show_value})
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

  def cat_label(category)
    category.constantize.humanized_category || short_cat(category)
  end

  def translate_full_name(setting)
    fullname = setting.full_name.nil? ? setting.name : _(setting.full_name)
    trunc_with_tooltip(fullname, 32, setting.name, false)
  end
end
