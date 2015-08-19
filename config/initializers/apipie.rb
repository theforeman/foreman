require 'find'

Apipie.configure do |config|
  config.app_name = "Foreman"
  config.app_info = "The Foreman is aimed to be a single address for all machines life cycle management."
  config.copyright = ""
  config.api_base_url = "/api"
  config.api_controllers_matcher = ["#{Rails.root}/app/controllers/api/**/*.rb"]
  config.ignored = []
  config.ignored_by_recorder = %w[]
  config.doc_base_url = "/apidoc"
  config.use_cache = Rails.env.production? || File.directory?(config.cache_dir)
  # config.languages = [] # turn off localized API docs and CLI, useful for development
  config.languages = ENV['FOREMAN_APIPIE_LANGS'].try(:split, ' ') || FastGettext.available_locales
  config.default_locale = FastGettext.default_locale
  config.locale = lambda { |loc| loc ? FastGettext.set_locale(loc) : FastGettext.locale }

  substitutions = {
    :operatingsystem_families => Operatingsystem.families.join(", "),
    :providers => ComputeResource.providers.join(', '),
    :default_nic_type => InterfaceTypeMapper::DEFAULT_TYPE.humanized_name.downcase,
  }

  config.translate = lambda do |str, loc|
    old_loc = FastGettext.locale
    FastGettext.set_locale(loc)
    if str
      trans = _(str)
      trans = trans % substitutions
    end
    FastGettext.set_locale(old_loc)
    trans
  end
  config.validate = false
  config.force_dsl = true
  config.reload_controllers = Rails.env.development?
  config.markup = Apipie::Markup::Markdown.new if Rails.env.development? and defined? Maruku
  config.default_version = "v1"
  config.update_checksum = true
  config.checksum_path = ['/api/', '/apidoc/']
end

# check apipie cache in dev mode
if Apipie.configuration.use_cache
  cache_name = File.join(Apipie.configuration.cache_dir, Apipie.configuration.doc_base_url + '.json')
  if File.exist? cache_name
    target = max = File.mtime(cache_name)
    roots = Rails.application.railties.engines.collect{ |e| e.root }
    roots << Rails.root
    roots.each do |root|
      path = "#{root}/app/controllers/api"
      Find.find(path) do |e|
        t = File.mtime(e)
        max = t if t > max
      end if File.exist?(path)
    end
    if ! $ARGV.nil? && $ARGV.first != "apipie:cache" && max > target
      puts "API controllers newer than Apipie cache! Run apipie:cache rake task to regenerate cache."
    end
  else
    puts "Apipie cache enabled but not present yet. Run apipie:cache rake task to speed up API calls."
  end
else
  puts "The Apipie cache is turned off. Enable it and run apipie:cache rake task to speed up API calls."
end

# special type of validator: we say that it's not specified
class UndefValidator < Apipie::Validator::BaseValidator
  def validate(value)
    true
  end

  def self.build(param_description, argument, options, block)
    self.new(param_description) if argument == :undef
  end

  def description
    nil
  end
end

class IdentifierValidator < Apipie::Validator::BaseValidator
  def validate(value)
    value = value.to_s
    value =~ /\A[\w| |_|-]*\Z/ && value.strip == value && (1..128).include?(value.length)
  end

  def self.build(param_description, argument, options, block)
    self.new(param_description) if argument == :identifier
  end

  def description
    "Must be an identifier, string from 1 to 128 characters containing only alphanumeric characters, " +
        "space, underscore(_), hypen(-) with no leading or trailing space."
  end
end

class IdentifierDottableValidator < Apipie::Validator::BaseValidator
  def validate(value)
    value = value.to_s
    value =~ /\A[\w| |_|-|.]*\Z/ && value.strip == value && (1..128).include?(value.length)
  end

  def self.build(param_description, argument, options, block)
    self.new(param_description) if argument == :identifier_dottable
  end

  def description
    "Must be an identifier, string from 1 to 128 characters containing only alphanumeric characters, " +
        "dot(.), space, underscore(_), hypen(-) with no leading or trailing space."
  end
end
