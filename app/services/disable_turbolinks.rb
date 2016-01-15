module DisableTurbolinks
  def self.pages_registry
    @pages_registry ||= Registry.new
  end

  def self.include?(path_hash)
    pages_registry.include? path_hash
  end

  def self.has_path?(path)
    pages_registry.has_path? path
  end

  def self.register(page_names)
    page_names.each { |name| pages_registry.register name }
  end

  def self.registered_pages
    pages_registry.pages
  end
end
