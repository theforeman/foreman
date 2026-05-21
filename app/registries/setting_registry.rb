class SettingRegistry
  include Singleton
  include Enumerable
  extend ScopedSearch::ClassMethods

  class SettingCompleter < ScopedSearch::AutoCompleteBuilder
    def initialize(registry, definition, query, options)
      @registry = registry
      super(definition, query, options)
    end

    def self.auto_complete(registry, definition, query, options)
      return [] if (query.nil? || definition.nil? || !definition.respond_to?(:fields))

      new(registry, definition, query, options).build_autocomplete_options
    end

    def is_query_valid
      true
    end

    def complete_value
      if last_token_is(COMPARISON_OPERATORS)
        token = tokens[tokens.size - 2]
        val = ''
      else
        token = tokens[tokens.size - 3]
        val = tokens[tokens.size - 1]
      end
      field = definition.field_by_name(token)
      return [] unless field&.complete_value
      complete_value_from_db(field, val)
    end

    def complete_value_from_db(field, val)
      count = 20
      case field.field
      when :name
        results = @registry.filter_map { |set| ((set.full_name =~ /\s/) ? "\"#{set.full_name.gsub('"', '\"')}\"" : set.full_name) if set.name.include?(val) || set.full_name&.include?(val) }
        results.first(count)
      when :description
        []
      else
        raise ScopedSearch::QueryNotSupported, "Value '#{val}' is not valid for field '#{field.field}'"
      end
    end
  end

  def self.subset_registry(subset)
    new(subset)
  end

  # -----=== Mimic ActiveRecord scope ===------
  def search_for(query, _options = {})
    return self if query.blank?
    subset = @settings.select { |name, definition| definition.matches_search_query?(query) }
    self.class.subset_registry(subset)
  end

  def paginate(page: nil, per_page: nil)
    page = (page || 1).to_i
    per_page = (per_page || Setting[:entries_per_page]).to_i
    subset_keys = @settings.keys[((page - 1) * per_page)..(page * per_page - 1)]
    self.class.subset_registry(@settings.slice(*subset_keys))
  end

  def empty?
    @settings.empty?
  end
  # -----=== END ===------

  def each(&block)
    @settings.values.each(&block)
  end

  def initialize(settings = {})
    @settings = settings
  end

  def ready?
    @settings.any?
  end

  def loaded?
    !!@last_reload_at
  end

  def logger
    Foreman::Logging.logger('app')
  end

  def select_collection_registry
    @select_collection_registry ||= SettingSelectCollection.new
  end

  def find(name)
    logger.warn("Setting is not initialized yet, requested value for #{name} will be always nil") unless ready?
    @settings[name.to_s]
  end

  # Returns a setting effective value
  # Call as `Foreman.settings[<name>]`
  #
  #   Foreman.settings['default_locale'] => nil.
  #   Foreman.settings[:default_locale] => nil.
  #
  def [](name)
    definition = find(name)
    unless definition
      logger.warn("Setting #{name} has no definition, please define it before using") if ready?
      return
    end
    definition.value
  end

  def []=(name, value)
    definition = find(name)
    raise ::Foreman::Exception.new(N_("Setting definition for '%s' not found, can not set"), name) unless definition
    db_record = _find_or_new_db_record(name)
    db_record.update!(value: value)
  end

  def set_user_value(name, value)
    definition = find(name)
    raise ActiveRecord::RecordNotFound.new(_("Setting definition for '%s' not found, can not set") % name, Setting, name) unless definition
    db_record = _find_or_new_db_record(name)

    type = value.class.to_s.downcase
    type = 'boolean' if type == "trueclass" || type == "falseclass"
    case type
    when 'string'
      db_record.parse_string_value(value)
    when definition.settings_type
      db_record.value = value
    else
      raise ::Foreman::SettingValueException.new(N_('expected a value of type %s'), definition.settings_type)
    end
    db_record
  end

  # Returns all the categories used for settings
  def categories
    return @categories unless @categories.nil?
    @categories = @settings.values.uniq(&:category).each_with_object({'general' => nil}) do |definition, memo|
      memo[definition.category_name] = definition.category_label
    end
    @categories.delete('general') if @categories['general'].nil?
    @categories
  end

  def category_settings(category)
    @settings.select { |_name, definition| definition.category_name == category.to_s }
  end

  def load
    # add() all setting definitions
    load_definitions
    Setting.descendants.each(&:load_defaults)

    # load all db values
    load_values(ignore_cache: true)

    # create missing settings in the database
    @settings.except(*Setting.unscoped.all.pluck(:name)).each do |name, definition|
      definition.updated_at = nil
    end
  end

  def load_definitions
    @settings = {}
    @categories = nil
    @select_collection_registry = nil

    Foreman::SettingManager.settings.each do |name, opts|
      _add(name, **opts)
    end
  end

  # Two-tier settings cache:
  # - Same-process: Setting#after_save updates the in-memory SettingPresenter directly
  # - Cross-process: Setting#after_commit bumps a shared cache counter so other
  #   Puma workers know to reload from DB on their next request
  # - Safety net: reload from DB every GENERATION_MAX_STALENESS seconds even if
  #   the generation counter appears current (guards against lost cache writes)
  SETTINGS_GENERATION_KEY = 'setting_registry:generation'
  GENERATION_MAX_STALENESS = 30.seconds

  def load_values(ignore_cache: false)
    return unless reload_required?(ignore_cache)

    Setting.unscoped.each do |s|
      unless (definition = find(s.name))
        logger.debug("Setting #{s.name} has no definition, clean up your database")
        next
      end
      definition.updated_at = s.updated_at
      definition.value_from_db = s.value
    end
    @last_reload_at = Time.zone.now
    @last_seen_generation = current_generation
  end

  def self.increment_generation!
    Rails.cache.increment(SETTINGS_GENERATION_KEY, 1, raw: true)
  rescue StandardError
    # Cache unavailable — next load_values will fall through to DB
  end

  def _add(name, category:, type:, default:, description:, full_name:, context:, encrypted: false, collection: nil, options: {})
    select_collection_registry.add(name, collection: collection, **options) if collection

    @settings[name.to_s] = SettingPresenter.new({ name: name,
                                                  context: context,
                                                  category: category,
                                                  settings_type: type.to_s,
                                                  description: description,
                                                  default: default,
                                                  full_name: full_name,
                                                  collection: collection,
                                                  encrypted: encrypted })
  end

  def _find_or_new_db_record(name)
    definition = find(name)
    Setting.find_by(name: name) || _new_db_record(definition)
  end

  def _new_db_record(definition)
    Setting.new(name: definition.name, value: definition.value)
  end

  private

  def reload_required?(ignore_cache)
    return true if ignore_cache || @last_reload_at.nil?
    return true if stale?
    !generation_current?
  end

  def generation_current?
    gen = current_generation
    return false if gen.nil?
    gen == @last_seen_generation
  end

  def current_generation
    Rails.cache.read(SETTINGS_GENERATION_KEY, raw: true)
  rescue StandardError
    nil
  end

  def stale?
    Time.zone.now - @last_reload_at > GENERATION_MAX_STALENESS
  end
end
