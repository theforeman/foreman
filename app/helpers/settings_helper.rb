module SettingsHelper

  def value f
    case f.object.settings_type
    when "boolean"
      f.select :value, options_for_select(["true", "false"]), :value => f.object.value.to_s
    else
      f.text_field :value, :value => f.object.value
    end
  end

end
