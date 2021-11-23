require 'tsort'

# ActiveRecord Callback class
# TODO: it would deserve its own folder
class EnsureNoCycle
  include TSort

  def initialize(base, source, target)
    @source, @target = source, target
    @base = base.map { |record| [record.send(@source), record.send(@target)] }
    @nodes = @base.flatten.uniq
    @graph = Hash.new { |h, k| h[k] = [] }
    @base.each { |s, t| @graph[s] << t }
  end

  def tsort_each_node(&block)
    @nodes.each(&block)
  end

  def tsort_each_child(node, &block)
    @graph[node].each(&block)
  end

  def ensure(record)
    @record = record
    add_new_edges
    detect_cycle
  end

  private

  def add_new_edges
    edges = @graph[@record.send(@source) || 0]
    edges << @record.send(@target) unless edges.include?(@record.send(@target))
  end

  def detect_cycle
    if strongly_connected_components.any? { |component| component.size > 1 }
      @record.errors.add :base, _("Adding would cause a cycle!")
      raise ::Foreman::CyclicGraphException, @record
    else
      true
    end
  end
end
