class FiltersHelperOverrides
  class << self
    def can_override?(class_or_engine_name)
      overrides.include?(deconstantize_name(class_or_engine_name))
    end

    def search_path(class_or_engine_name)
      overrides[deconstantize_name(class_or_engine_name)].call(class_or_engine_name)
    end

    private

    def deconstantize_name(name)
      name.include?('::') ? name.deconstantize : name
    end

    def overrides
      Foreman::Plugin.all.inject({}) { |all, plugin| all.update(plugin.search_overrides) }
    end
  end

  private

  def initialize
  end
end
