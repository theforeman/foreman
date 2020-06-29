require 'find'

ApipieDSL.configure do |config|
  config.default_version = 'v1'
  config.app_name = 'Foreman'
  config.app_info = 'The Foreman is aimed to be a single address for all machines life cycle management.'
  config.doc_base_url = '/templates_doc'
  config.markup = ApipieDSL::Markup::Markdown.new if Rails.env.development? && defined? Maruku
  config.dsl_classes_matchers = [
    "#{Rails.root}/app/models/**/*.rb",
    "#{Rails.root}/lib/foreman/renderer/**/*.rb",
  ]

  config.sections = %w[all reports provisioning jobs partition_tables additional basic_ruby_methods]
  # TODO enable?
  config.validate = false

  config.use_cache = Rails.env.production? || File.directory?(config.cache_dir)
  # config.languages = [] # turn off localized DSL docs, useful for development
  config.languages = ENV['FOREMAN_APIPIE_LANGS'].try(:split, ' ') || FastGettext.available_locales
  config.default_locale = FastGettext.default_locale
  config.locale = ->(loc) { loc ? FastGettext.set_locale(loc) : FastGettext.locale }

  config.translate = lambda do |str, loc|
    old_loc = FastGettext.locale
    FastGettext.set_locale(loc)
    trans = _(str) if str
    FastGettext.set_locale(old_loc)
    trans
  end
  config.help_layout = 'apipie_dsl/apipie_dsls/help.html.erb'
end

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
  config.locale = ->(loc) { loc ? FastGettext.set_locale(loc) : FastGettext.locale }

  substitutions = {
    :operatingsystem_families => Operatingsystem.families.join(", "),
    :providers => -> { ComputeResource.providers.keys.join(', ') },
    :providers_requiring_url => -> { ComputeResource.providers_requiring_url },
    :default_nic_type => InterfaceTypeMapper::DEFAULT_TYPE.humanized_name.downcase,
    :template_kinds => -> { Rails.cache.fetch("template_kind_names", expires_in: 1.hour) { TemplateKind.pluck(:name).join(", ") } },
    :host_rebuild_steps => -> { Host::Managed.valid_rebuild_only_values.join(', ') },
  }

  config.translate = lambda do |str, loc|
    old_loc = FastGettext.locale
    FastGettext.set_locale(loc)
    if str
      trans = _(str)
      trans = trans % Hash[substitutions.map { |k, v| [k, v.respond_to?(:call) ? v.call : v] }]
    end
    FastGettext.set_locale(old_loc)
    trans
  end
  config.validate = false
  config.force_dsl = true
  config.reload_controllers = Rails.env.development?
  config.markup = Apipie::Markup::Markdown.new if Rails.env.development? && defined? Maruku
  config.default_version = "v2"
  config.update_checksum = true
  config.checksum_path = ['/api/', '/apidoc/']
end

# check apipie cache in dev mode
if Apipie.configuration.use_cache
  cache_name = File.join(Apipie.configuration.cache_dir, Apipie.configuration.doc_base_url + '.json')
  if File.exist?(cache_name)
    target = File.mtime(cache_name)
    roots = ::Rails::Engine.subclasses.map { |e| e.instance.root }
    roots << Rails.root
    outdated = roots.any? do |root|
      path = "#{root}/app/controllers/api"
      File.exist?(path) && Find.find(path).any? do |e|
        File.mtime(e) > target
      end
    end
    if !$ARGV.nil? && $ARGV.first != "apipie:cache" && outdated
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
    new(param_description) if argument == :undef
  end

  def description
    nil
  end
end

class IdentifierValidator < Apipie::Validator::BaseValidator
  def validate(value)
    value = value.to_s
    value =~ /\A[\w| |_|-]*\Z/ && value.strip == value && (1..128).cover?(value.length)
  end

  def self.build(param_description, argument, options, block)
    new(param_description) if argument == :identifier
  end

  def description
    "Must be an identifier, string from 1 to 128 characters containing only alphanumeric characters, " +
        "space, underscore(_), hypen(-) with no leading or trailing space."
  end
end

class IdentifierDottableValidator < Apipie::Validator::BaseValidator
  def validate(value)
    value = value.to_s
    value =~ /\A[\w| |_|-|.]*\Z/ && value.strip == value && (1..128).cover?(value.length)
  end

  def self.build(param_description, argument, options, block)
    new(param_description) if argument == :identifier_dottable
  end

  def description
    "Must be an identifier, string from 1 to 128 characters containing only alphanumeric characters, " +
        "dot(.), space, underscore(_), hypen(-) with no leading or trailing space."
  end
end

# Allows to enumerate multiple types that a parameter accepts.
class AnyTypeValidator < Apipie::Validator::BaseValidator
  def initialize(param_description, argument, options = {})
    super(param_description)
    @allowed_types = options[:of] || []
  end

  def validate(value)
    # The validator has rather informative value, skip the real validation
    true
  end

  def self.build(param_description, argument, options, block)
    if argument == :any_type
      new(param_description, argument, options)
    end
  end

  def description
    if @allowed_types.empty?
      'Can be any type'
    else
      types = @allowed_types.map { |type| "<code>#{type}</code>" }.join(', ')
      'Must be one of types: %s' % types
    end
  end

  def expected_type
    :any_type
  end
end
