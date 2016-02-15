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
      case setting.name
      when "default_location"
        edit_select(setting, :value, {:select_values => Hash[Location.all.map{|loc| [loc[:title], loc[:title]]}].to_json } )
      when "default_organization"
        edit_select(setting, :value, {:select_values => Hash[Organization.all.map{|org| [org[:title], org[:title]]}].to_json } )
      when "default_puppet_environment"
        edit_select(setting, :value, {:select_values => Hash[Environment.all.map{|env| [env[:name], env[:name]]}].to_json } )
      else
        edit_textfield(setting, :value,{:helper => :show_value})
      end
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

  def translate_full_name(setting)
    fullname = setting.full_name.nil? ? setting.name : _(setting.full_name)
    trunc_with_tooltip(fullname, 32, setting.name, false)
  end
end
