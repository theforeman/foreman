module Orchestration
  class Task
    attr_reader :name, :status, :priority, :action, :timestamp

    def initialize(opts)
      @name      = opts[:name]
      @status    = opts[:status]
      @priority  = opts[:priority] || 0
      @action    = opts[:action]
      update_ts
    end

    def status=(s)
      if Orchestration::Queue::STATUS.include?(s)
        update_ts
        @status = s
      else
        raise "invalid STATE #{s}"
      end
    end

    def to_s
      "#{name}\t #{priority}\t #{status}\t #{action}"
    end

    def as_json(options = {})
      {:name => name, :timestamp => timestamp, :status => status, :priority => priority}.as_json
    end

    private

    def update_ts
      @timestamp = Time.now
    end

    # sort based on priority
    def <=>(other)
      self.priority <=> other.priority
    end
  end
end
