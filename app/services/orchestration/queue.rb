require_dependency 'orchestration/task'

module Orchestration
  # Represents tasks queue for orchestration
  class Queue
    attr_reader :items, :name
    STATUS = %w[pending running failed completed rollbacked conflict canceled]

    delegate :count, :size, :empty?, :to => :items
    delegate :to_json, :to => :all
    delegate :to_s, :to => :name

    def initialize(name = "Unnamed")
      @items = []
      @name = name
    end

    def create(options)
      options[:status] ||= default_status
      new_task = Task.new(options)
      if items.include? new_task
        # Two tasks with same :name are not allowed. Use two different :id options for multiple instances.
        Rails.logger.debug "Task '#{new_task.id || new_task.name || ''}' already in '#{name}' queue"
      else
        Rails.logger.debug "Enqueued task '#{new_task.id || new_task.name || ''}' to '#{name}' queue"
        items << new_task
      end
    end

    def delete(item)
      @items.delete item
    end

    def find_by_name(name)
      items.detect { |task| task.name == name }
    end

    def find_by_id(id)
      string_id = id.to_s
      items.detect { |task| task.id == string_id }
    end

    def all
      items.sort
    end

    def task_ids
      all.map(&:id)
    end

    def clear
      @items = []
      true
    end

    STATUS.each do |s|
      define_method s do
        all.delete_if { |t| t.status != s }.sort
      end
    end

    private

    def default_status
      "pending"
    end
  end
end
