class SettingRegistry
  include Singleton
  include Enumerable

  def self.subset_registry(subset)
    new(subset)
  end

  def search_for(query)
    return self if query.blank?
    subset = @settings.select { |name, definition| definition.matches_search_query?(query) }
    self.class.subset_registry(subset)
  end

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
    db_record.value = value
    db_record.save!
    definition.value = db_record.value
  end

  # Returns all the categories used for settings
  def categories
    sticked_general = { 'General' => nil }
    sticked_general.merge!(Hash[@settings.map { |_name, definition| [definition.category_name, definition.category_label] }])
    sticked_general.delete('General') if sticked_general['General'].nil?
    sticked_general
  end

  def load
    # add() all setting definitions
    load_definitions

    # load all db values
    load_values

    # if create_missing create missing values in DB
    # not needed now as old load mechanism takes care of that
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

  def load_values
    loaded_names = []
    Setting.unscoped.all.each do |s|
      unless (definition = find(s.name))
        logger.debug("Setting #{s.name} has no definition, clean up your database")
        next
      end
      loaded_names << s.name
      definition.updated_at = s.updated_at
      definition.value = s.value
    end
    # load nil to set value to default
    @settings.except(*loaded_names).each do |name, definition|
      definition.updated_at = nil
      definition.value = definition.default
    end
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
