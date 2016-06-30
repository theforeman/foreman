module Updates
  def self.register_source(class_name, opts = {})
    registry.add(class_name.new opts)
  end

  def self.registry
    @registry ||= Set.new
  end

  def self.find(name)
    registry.find { |update| update.humanized_name == name}
  end
end

require_dependency 'updates/base'
require_dependency 'updates/wiki'
