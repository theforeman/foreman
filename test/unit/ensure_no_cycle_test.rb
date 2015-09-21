require 'test_helper'

def OpenStruct.i18n_scope
  :en
end

class EnsureNoCycleTest < ActiveSupport::TestCase
  def setup
    base = []
    base.push edge(1, 2)
    base.push edge(2, 3)
    base.push edge(3, 4)
    base.push edge(3, 5)
    base.push edge(2, 6)
    @graph = ActiveRecord::Base::EnsureNoCycle.new(base, :source, :target)
  end

  #apparently, ActiveModel::Errors calls that...
  def self.i18n_scope
    :en
  end

  def edge(source, target)
    OpenStruct.new(:source => source, :target => target)
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
    record = edge(6, 1)
    record.errors = ActiveModel::Errors.new(record)
    assert_raises Foreman::CyclicGraphException do
      @graph.ensure(record)
    end
    assert record.errors[:base].present?, 'cycle did not add error to record'
  end

  test "#ensure passes when record does not create cycle" do
    record = edge(2, 4)
    assert_nothing_raised do
      assert @graph.ensure(record)
    end
  end
end
