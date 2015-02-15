class FiltersHelperOverrides
  @@overrides = {}

  def self.override_search_path(module_or_engine_name, blk)
    @@overrides[module_or_engine_name] = blk
  end

  def self.can_override?(class_or_engine_name)
    @@overrides.include?(class_or_engine_name.deconstantize)
  end

  def self.search_path(class_or_engine_name)
    @@overrides[class_or_engine_name.deconstantize].call(class_or_engine_name)
  end

  private

  def initialize; end
end
