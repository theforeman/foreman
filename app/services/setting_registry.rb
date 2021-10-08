class SettingRegistry
  include Singleton

  def initialize
    @settings = {}
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
    db_record.value = value
    db_record.save!
    definition.value = db_record.value
  end

  def load
    # add() all setting definitions
    load_definitions

    # load all db values
    load_values(ignore_cache: true)

    # load nil to set value to default
    @settings.except(*Setting.unscoped.pluck(:name)).each do |name, definition|
      definition.updated_at = nil
      definition.value = definition.default
    end
  end

  def load_definitions
    Setting.descendants.each do |cat_cls|
      if cat_cls.default_settings.empty?
        # Setting category uses really old way of doing things
        _load_category_from_db(cat_cls)
      else
        cat_cls.default_settings.each { |s| _add(s[:name], s.except(:name).merge(category: cat_cls.name)) }
      end
    end
  end

  def known_categories
    unless @known_descendants == Setting.descendants
      @known_descendants = Setting.descendants
      @known_categories = @known_descendants.map(&:name)
      @values_loaded_at = nil # force all values to be reloaded
    end
    @known_categories
  end

  def load_values(ignore_cache: false)
    # we are loading only known STIs as we load settings fairly early the first time and plugin classes might not be loaded yet.
    settings = Setting.unscoped.where(category: known_categories)
    settings = settings.where('updated_at >= ?', @values_loaded_at) unless ignore_cache || @values_loaded_at.nil?
    settings.each do |s|
      unless (definition = find(s.name))
        logger.debug("Setting #{s.name} has no definition, clean up your database")
        next
      end
      definition.updated_at = s.updated_at
      definition.value = s.value
      logger.debug("Updated cached value for setting=#{s.name}") unless ignore_cache
    end
    @values_loaded_at = Time.zone.now if settings.any?
  end

  def _add(name, category:, default:, description:, full_name: nil, value: nil, encrypted: false)
    @settings[name.to_s] = SettingPresenter.new({ name: name,
                                                  category: category,
                                                  description: description,
                                                  default: default,
                                                  full_name: full_name,
                                                  encrypted: encrypted })
  end

  def _find_or_new_db_record(name)
    definition = find(name)
    Setting.find_by(name: name) ||
      Setting.new(name: name,
                  category: definition.category,
                  default: definition.default,
                  description: definition.description,
                  full_name: definition.full_name,
                  encrypted: definition.encrypted?)
  end

  # ==== Load old defaults

  def _load_category_from_db(category_klass)
    category_klass.all.each do |set|
      # set.value can be user value, we have no way of telling the initial value
      _add(set.name, category: category_klass.name, description: set.description, default: set.default, full_name: set.full_name, encrypted: set.encrypted)
    end
  end
end
