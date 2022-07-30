module HostStatus
  class StatusRegistry < Set
    # Jail is not inherited so whenever a new host status type is registered (added)
    # we dynamically define the same Jail that base status class has
    def add(klass)
      klass.const_set('Jail', HostStatus::Status::Jail) unless klass.const_defined?('Jail', false)
      super
    end
  end
end
