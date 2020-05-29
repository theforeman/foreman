class SettingSelectCollection
  def initialize
    @collection_mapping = {}
  end

  def add(name, options)
    @collection_mapping[name] = options
  end

  def has_collection?(setting)
    @collection_mapping.has_key? setting.name
  end

  def collection_for(setting)
    opts = @collection_mapping[setting.name]
    return unless opts
    SettingValueSelection.new(opts[:collection].call, opts).collection
  end
end
