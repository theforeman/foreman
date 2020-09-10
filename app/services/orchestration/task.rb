module Orchestration
  class Task
    attr_reader :id, :name, :status, :priority, :action, :timestamp, :created

    def initialize(opts)
      @name      = opts[:name]
      @id        = opts[:id].try(:to_s) || @name
      @status    = opts[:status]
      @priority  = opts[:priority] || 0
      @action    = opts[:action]
      @created   = opts[:created] || Time.now.to_f
      raise("action must be present for task '#{name}'") if action.nil?
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

    def status?(symbol)
      @status == symbol.to_s
    end

    def to_s
      tid = id.nil? ? '' : " (#{id})"
      "#{name}#{tid}\t #{priority}\t #{status}\t #{action}"
    end

    def as_json(options = {})
      { :id => id, :name => name, :timestamp => timestamp, :status => status, :priority => priority, :created => created }
    end

    private

    def update_ts
      @timestamp = Time.now.utc
    end

    # sort based on priority
    def <=>(other)
      return created <=> other.created if priority == other.priority
      priority <=> other.priority
    end

    def ==(other)
      return false unless other.is_a?(Task)
      id == other.id
    end
  end
end
