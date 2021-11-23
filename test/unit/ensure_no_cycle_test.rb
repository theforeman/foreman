require 'test_helper'

class EnsureNoCycleTest < ActiveSupport::TestCase
  def setup
    base = []
    base.push Edge.new(1, 2)
    base.push Edge.new(2, 3)
    base.push Edge.new(3, 4)
    base.push Edge.new(3, 5)
    base.push Edge.new(2, 6)
    @graph = EnsureNoCycle.new(base, :source, :target)
  end

  class Edge < OpenStruct
    include ActiveModel::Validations
    extend ActiveModel::Naming
    attr_accessor :source, :target

    def initialize(source, target)
      self.source = source
      self.target = target
    end
  end

  test "#tsort_each_node iterates over all nodes" do
    found = []
    @graph.tsort_each_node { |node| found.push node }
    assert_equal [1, 2, 3, 4, 5, 6], found
  end

  test "#tsort_each_child(node) finds all children for node" do
    found = []
    assert @graph.tsort_each_child(1) { |node| found.push node }
    assert_equal [2], found

    found = []
    assert @graph.tsort_each_child(2) { |node| found.push node }
    assert_equal [3, 6], found

    found = []
    assert @graph.tsort_each_child(3) { |node| found.push node }
    assert_equal [4, 5], found

    found = []
    assert @graph.tsort_each_child(4) { |node| found.push node }
    assert_equal [], found
  end

  test "#ensure detects cycle and raises an exception" do
    record = Edge.new(6, 1)
    assert_raises Foreman::CyclicGraphException do
      @graph.ensure(record)
    end
    assert record.errors[:base].present?, 'cycle did not add error to record'
  end

  test "#ensure passes when record does not create cycle" do
    record = Edge.new(2, 4)
    assert_nothing_raised do
      assert @graph.ensure(record)
    end
  end
end
