class FiltersHelperOverrides
  @@overrides = {}

  def self.override_search_path(module_or_engine_name, blk)
    @@overrides[module_or_engine_name] = blk
  end

  def self.can_override?(class_or_engine_name)
    @@overrides.include?(deconstantize_name(class_or_engine_name))
  end

  def self.search_path(class_or_engine_name)
    @@overrides[deconstantize_name(class_or_engine_name)].call(class_or_engine_name)
  end

  def self.deconstantize_name(name)
    name.include?('::') ? name.deconstantize : name
  end

  private

  def initialize; end
end
