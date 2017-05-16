require_dependency 'orchestration/task'

module Orchestration
  # Represents tasks queue for orchestration
  class Queue
    attr_reader :items, :name
    STATUS = %w[ pending running failed completed rollbacked conflict canceled]

    delegate :count, :empty?, :to => :items
    delegate :to_json, :to => :all
    delegate :to_s, :to => :name

    def initialize(name = "Unnamed")
      @items = []
      @name = name
    end

    def create(options)
      options[:status] ||= default_status
      Rails.logger.debug "Enqueued task '#{options[:name]}' to '#{name}' queue"
      items << Task.new(options)
    end

    def delete(item)
      @items.delete item
    end

    def find_by_name(name)
      items.each {|task| return task if task.name == name}
    end

    def all
      items.sort
    end

    def clear
      @items = []
      true
    end

    STATUS.each do |s|
      define_method s do
        all.delete_if {|t| t.status != s}.sort
      end
    end

    private

    def default_status
      "pending"
    end
  end
end
