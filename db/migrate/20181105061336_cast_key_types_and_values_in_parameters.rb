class CastKeyTypesAndValuesInParameters < ActiveRecord::Migration[5.2]
  def up
    Parameter.skip_permission_check do
      Parameter.unscoped.each do |parameter|
        if parameter.value.contains_erb?
          save_param(parameter, parameter.value, 'string')
          next
        end
        next unless parameter.value.is_a? String
        override_key_type_and_value(parameter)
      end
    end
  end

  private

  def override_key_type_and_value(param)
    key_type_name = 'string'
    value = YAML.load param.value
    key_type_name = value.is_a?(Hash) ? 'yaml' : find_key_type(value)
  rescue Psych::SyntaxError
    value = JSON.load param.value.gsub('=>', ':')
    key_type_name = find_key_type(value)
  rescue StandardError, LoadError => e
    value = param.value
    say "Failed to cast #{value} for #{param.inspect}"
    say "Error: #{e.message}"
  ensure
    save_param(param, value, key_type_name)
  end

  def save_param(param, new_value, new_key_type)
    if Parameter::KEY_TYPES.include?(new_key_type)
      result = param.update_columns(value: new_value, key_type: new_key_type)
      return if result
      say "Failed to update param(#{param.id}): #{param.inspect}"
    else
      say "Failed to cast value #{param.value} of param(#{param.id}): #{param.inspect}"
    end
  end

  def find_key_type(param_value)
    return 'boolean' if [true, false].include?(param_value)
    param_value.class.name.underscore.humanize.downcase
  end
end
