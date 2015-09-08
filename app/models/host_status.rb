module HostStatus
  def self.status_registry
    @status_registry ||= Set.new
  end

  def self.find_status_by_humanized_name(name)
    status_registry.find { |s| s.humanized_name == name }
  end
end

require_dependency 'host_status/status'
