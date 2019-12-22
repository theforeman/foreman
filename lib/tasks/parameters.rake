namespace :parameters do
  desc 'Reset parameter priorities in case they were changed'
  task :reset_priorities => :environment do
    Parameter.reorder('').distinct.pluck(:type).each do |type|
      priority = Parameter.type_priority(type)
      Parameter.reorder('').where(type: type).update_all(priority: priority)
    end
  end

  desc <<~END_DESC
    Auto detect the key type & update formatted value in parameters.

    Foreman will make auto detect key type based on the formatted value.
    This formatted value is nothing but parsed from string value of an existing parameters.
    It will update type and value with formatted value to parameters.

    Sample examples:
      if value == "123" then set type "integer" with value 123.

    Example:
        rake db:cast_key_types_and_values

  END_DESC
  task :cast_key_types_and_values => :environment do
    def override_key_type_and_value(param)
      key_type_name = 'string'
      value = YAML.load param.value
      key_type_name = value.is_a?(Hash) ? 'yaml' : find_key_type(value)

      # Avoid updating parameter with true/false when param.value
      # contains string like ("true"/"false", "yes"/"no" or "on"/"off").
      if key_type_name.eql?('boolean')
        key_type_name = 'string'
        value = param.value
      end
    rescue Psych::SyntaxError
      begin
        value = JSON.load param.value.gsub('=>', ':')
        key_type_name = find_key_type(value)
      rescue => e
        value = param.value
        puts "Failed to cast #{value} for #{param.inspect}"
        puts "Error: #{e.message}"
        puts e.backtrace[0..5].to_s
        puts "Resuming existing value #{value} as it is and type as string for this param"
      end
    ensure
      save_param(param, value, key_type_name)
    end

    def save_param(param, new_value, new_key_type)
      if Parameter::KEY_TYPES.include?(new_key_type)
        result = param.update_columns(value: new_value, key_type: new_key_type)
        return if result
        puts "Failed to update param(#{param.id}): #{param.inspect}"
      else
        puts "Failed to cast value #{param.value} of param(#{param.id}): #{param.inspect}"
      end
    end

    def find_key_type(param_value)
      return 'boolean' if [true, false].include?(param_value)
      param_value.class.name.underscore.humanize.downcase
    end

    User.as_anonymous_admin do
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
  end
end
