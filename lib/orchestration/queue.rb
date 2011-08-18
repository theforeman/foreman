require 'task'
module Orchestration
  # Represents tasks queue for orchestration
  class Queue

    attr_reader :items
    STATUS = %w[ pending running failed completed rollbacked conflict ]

    def initialize
      @items = []
    end

    def create options
      options[:status] ||= default_status
      items << Task.new(options)
    end

    def delete item
      @items.delete item
    end

    def find_by_name name
      items.each {|task| return task if task.name == name}
    end

    def all
      items.sort
    end

    def count
      items.count
    end

    def empty?
      items.empty?
    end

    def clear
      @items = [] && true
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
