module Orchestration
  class Task
    attr_reader :name, :status, :priority, :action, :timestamp

    def initialize opts
      @name      = opts[:name]
      @status    = opts[:status]
      @priority  = opts[:priority] || 0
      @action    = opts[:action]
      update_ts
    end

    def status=s
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

    def as_json options = {}
      super :only => [:name, :timestamp, :status]
    end

    private
    def update_ts
      @timestamp = Time.now
    end

    # sort based on priority
    def <=> other
      self.priority <=> other.priority
    end

  end
end
