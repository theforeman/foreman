Apipie.configure do |config|
  config.app_name = "Foreman"
  config.app_info = "The Foreman is aimed to be a single address for all machines life cycle management."
  config.copyright = ""
  config.api_base_url = "/api"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v1/*.rb"
  config.ignored_by_recorder = %w[]
  config.doc_base_url = "/apidoc"
  config.use_cache = Rails.env.production?
  config.validate = false
  config.force_dsl = true
  config.reload_controllers = Rails.env.development?
  config.markup = Apipie::Markup::Markdown.new if Rails.env.development?
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

  def description
    "Must be an identifier, string from 2 to 128 characters containting only alphanumeric characters, " +
        "space, '_', '-' with no leading or trailing space.."
  end
end
