module SettingsHelper

  def value f
    case f.object.settings_type
    when "boolean"
      f.select :value, options_for_select(["true", "false"], f.object.value.to_s), :class => "span-3 last"
    else
      f.text_field :value, :value => f.object.value, :class => "span-10 last"
    end
  end

  def show_value setting
    case setting.settings_type
    when "array"
      "[ " + setting.value.join(", ") + " ]"
    else
      setting.value
    end
  end
end
