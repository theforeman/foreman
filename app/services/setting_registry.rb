class SettingRegistry
  include Singleton
  include Enumerable

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

  def logger
    Foreman::Logging.logger('app')
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
    db_record.send(:set_setting_type_from_value)

    type = value.class.to_s.downcase
    type = 'boolean' if type == "trueclass" || type == "falseclass"
    case type
    when 'string'
      db_record.parse_string_value(value)
    when db_record.settings_type
      db_record.value = value
    else
      raise ::Foreman::Exception.new(N_('expected a value of type %s'), @setting.settings_type)
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

    # load all db values
    load_values(ignore_cache: true)

    # create missing settings in the database
    @settings.except(*Setting.unscoped.all.pluck(:name)).each do |name, definition|
      # Creating missing records as we operate over the DB model while updating the setting
      _new_db_record(definition).save(validate: false)
      definition.updated_at = nil
    end
  end

  def load_definitions
    @settings = {}
    @categories = nil

    Setting.descendants.each do |cat_cls|
      if cat_cls.default_settings.empty?
        Foreman::Deprecation.deprecation_warning('3.3', "subclassing Setting is deprecated '#{cat_cls.name}' should be migrated to setting DSL "\
                                                        'see https://github.com/theforeman/foreman/blob/develop/developer_docs/how_to_create_a_plugin.asciidoc#settings for details')
        next unless (Setting.table_exists? rescue(false))
        # Setting category uses really old way of doing things
        _load_category_from_db(cat_cls)
      else
        cat_cls.default_settings.each do |s|
          t = Setting.setting_type_from_value(s[:default]) || 'string'
          _add(s[:name], s.except(:name).merge(type: t.to_sym, category: cat_cls.name, context: :deprecated))
        end
      end
    end

    Foreman::SettingManager.settings.each do |name, opts|
      _add(name, opts)
    end
  end

  def known_categories
    unless @known_descendants == Setting.descendants
      @known_descendants = Setting.descendants
      @known_categories = @known_descendants.map(&:name) << 'Setting'
      @values_loaded_at = nil # force all values to be reloaded
    end
    @known_categories
  end

  def load_values(ignore_cache: false)
    # we are loading only known STIs as we load settings fairly early the first time and plugin classes might not be loaded yet.
    settings = Setting.unscoped.where(category: known_categories).where.not(value: nil)
    settings = settings.where('updated_at >= ?', @values_loaded_at) unless ignore_cache || @values_loaded_at.nil?
    settings.each do |s|
      unless (definition = find(s.name))
        logger.debug("Setting #{s.name} has no definition, clean up your database")
        next
      end
      definition.updated_at = s.updated_at
      definition.value_from_db = s.value
      logger.debug("Updated cached value for setting=#{s.name}") unless ignore_cache
    end
    @values_loaded_at = Time.zone.now if settings.any?
  end

  def _add(name, category:, type:, default:, description:, full_name:, context:, value: nil, encrypted: false, collection: nil, options: {})
    Setting.select_collection_registry.add(name, collection: collection, **options) if collection
    Foreman::Deprecation.deprecation_warning('3.3', "initial value of setting '#{name}' should be created in a migration") if value

    @settings[name.to_s] = SettingPresenter.new({ name: name,
                                                  context: context,
                                                  category: category,
                                                  settings_type: type.to_s,
                                                  description: description,
                                                  default: default,
                                                  value: value,
                                                  full_name: full_name,
                                                  collection: collection,
                                                  encrypted: encrypted })
  end

  def _find_or_new_db_record(name)
    definition = find(name)
    Setting.find_by(name: name) || _new_db_record(definition)
  end

  def _new_db_record(definition)
    Setting.new(name: definition.name,
                category: definition.category.safe_constantize&.name || 'Setting',
                default: definition.default,
                value: definition.value,
                description: definition.description)
  end

  # ==== Load old defaults

  def _load_category_from_db(category_klass)
    category_klass.all.each do |set|
      # set.value can be user value, we have no way of telling the initial value
      _add(set.name, type: (set.settings_type || 'string').to_sym, category: category_klass.name, description: set.description, default: set.default, full_name: set.try(:full_name), context: :deprecated, encrypted: set.try(:encrypted))
    end
  end
end
