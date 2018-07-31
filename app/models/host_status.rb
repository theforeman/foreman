module HostStatus
  class StatusRegistry < Set
    # Jail is not inherited so whenever a new host status type is registered (added)
    # we dynamically define the same Jail that base status class has
    def add(klass)
      klass.const_set('Jail', HostStatus::Status::Jail) unless klass.const_defined?('Jail', false)
      super
    end
  end

  def self.status_registry
    @status_registry ||= StatusRegistry.new
  end

  def self.find_status_by_humanized_name(name)
    status_registry.find { |s| s.humanized_name == name }
  end
end

require_dependency 'host_status/status'
