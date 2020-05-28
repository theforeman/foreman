module SettingsHelper
  def setting_presenter(setting)
    presenter = Foreman.setting_manager.settings[setting.name]
    Rails.logger.warn("Setting #{setting.name} is not defined in #{setting.category}#default_settings.") unless presenter
    presenter
  end

  def value(presenter)
    if presenter.readonly?
      return readonly_field(presenter, :value,
        {:title => _("This setting is defined in the configuration file '%{filename}' and is read-only.") % {:filename => presenter.category.constantize.config_file}, :helper => :show_value})
    end

    if presenter.has_collection?
      return edit_select(presenter, :value,
        {:title => setting_full_name_with_default(presenter), :select_values => setting_collection_for(presenter) })
    end

    placeholder = presenter.has_default? ? presenter.default : "No default value was set"
    return edit_textarea(presenter, :value, {:title => setting_full_name_with_default(presenter), :helper => :show_value, :placeholder => placeholder}) if presenter.settings_type == 'array'
    edit_textfield(presenter, :value, {:title => setting_full_name_with_default(presenter), :helper => :show_value, :placeholder => placeholder})
  end

  def show_value(presenter)
    case presenter.settings_type
    when "array"
      "[ " + presenter.value.join(", ") + " ]"
    else
      presenter.safe_value
    end
  rescue
    presenter.value
  end

  def short_cat(category)
    category.gsub(/Setting::/, '')
  end

  def cat_label(category)
    category.constantize.humanized_category || short_cat(category)
  end

  def setting_collection_for(presenter)
    opts = presenter.options
    SettingValueSelection.new(opts[:collection].call, opts).collection
  end

  def setting_full_name_with_default(presenter)
    default_label = presenter.has_default? ? presenter.default : 'Not set'
    "#{presenter.translated_full_name} (#{_('Default')}: #{default_label})"
  end
end
