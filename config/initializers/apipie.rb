Apipie.configure do |config|
  config.app_name = "Foreman"
  config.app_info = "The Foreman is aimed to be a single address for all machines life cycle management."
  config.copyright = ""
  config.api_base_url = "/api"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v1/*.rb"
  config.ignored_by_recorder = %w[]
  config.doc_base_url = "/apidoc"
  config.use_cache = false #Rails.env.production?
  config.validate = false
  config.reload_controllers = true
  config.markup = Apipie::Markup::Markdown.new
end

# special type of validator: we say that it's not specified
class UndefValidator < Apipie::Validator::BaseValidator

  def validate(value)
    true
  end

  def self.build(param_description, argument, options, block)
    if argument == :undef
      self.new(param_description)
    end
  end

  def description
    nil
  end
end

class Apipie::Validator::TypeValidator
  def description
    @type.name
  end
end

class Apipie::Validator::HashValidator
  def description
    "Hash"
  end
end

class NumberValidator < Apipie::Validator::BaseValidator

  def validate(value)
    value.to_s =~ /^(0|[1-9]\d*)$/
  end

  def self.build(param_description, argument, options, block)
    if argument == :number
      self.new(param_description)
    end
  end

  def error
    "Parameter #{param_name} expecting to be a number, got: #{@error_value}"
  end

  def description
    "number."
  end
end

class IdentifierValidator < Apipie::Validator::BaseValidator

  def validate(value)
    value = value.to_s
    value =~ /\A[\w| |_|-]*\Z/ && value.strip == value && (2..128).include?(value.length)
  end

  def self.build(param_description, argument, options, block)
    if argument == :identifier
      self.new(param_description)
    end
  end

  def error
    "Parameter #{param_name} expecting to be an identifier, got: #{@error_value}"
  end

  def description
    "string from 2 to 128 characters containting only alphanumeric characters, space, '_', '-' with no leading or trailing space.."
  end
end

class BooleanValidator < Apipie::Validator::BaseValidator

  def validate(value)
    %w[true false].include?(value.to_s)
  end

  def self.build(param_description, argument, options, block)
    if argument == :bool
      self.new(param_description)
    end
  end

  def error
    "Parameter #{param_name} expecting to be a boolean value, got: #{@error_value}"
  end

  def description
    "boolean"
  end
end
