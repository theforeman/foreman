require 'test_helper'

class QueueTest < ActiveSupport::TestCase
  before do
    @queue = Orchestration::Queue.new
  end

  test 'a task can be added to queue' do
    assert_equal 1, @queue.create(name: "t1", id: "i1", action: [:blah]).count
  end

  test 'a task can be added to queue without id (deprecated behavior)' do
    assert_equal 1, @queue.create(name: "t1", action: [:blah]).count
  end

  test 'a task can be serialized to json' do
    @queue.create(name: "t1", id: "i1", action: [:blah], created: 1513246009.9976416)
    json = @queue.all.first.as_json
    assert_equal "i1", json[:id]
    assert_equal "t1", json[:name]
    assert_equal 1513246009.9976416, json[:created]
  end

  test 'a task can be searched by name' do
    @queue.create(name: "t1", id: "i1", action: [:blah])
    assert_nil @queue.find_by_name("")
    assert @queue.find_by_name("t1")
    assert_equal "t1", @queue.find_by_name("t1").name
  end

  test 'a task can be searched by id' do
    @queue.create(name: "t1", id: "i1", action: [:blah])
    assert_nil @queue.find_by_id("")
    assert @queue.find_by_id("i1")
    assert_equal "t1", @queue.find_by_id("i1").name
  end

  test 'a task can be searched by id as symbol' do
    @queue.create(name: "t1", id: :i1, action: [:blah])
    assert_equal "t1", @queue.find_by_id("i1").name
    assert_equal "t1", @queue.find_by_id(:i1).name
  end

  test 'two tasks with same id are not added' do
    @queue.create(id: "t1", action: [:blah])
    @queue.create(id: "t1", action: [:blah, :blah])
    assert_equal 1, @queue.count
  end

  test 'two tasks with same name are not added' do
    @queue.create(name: "t1", action: [:blah])
    @queue.create(name: "t1", action: [:blah, :blah])
    assert_equal 1, @queue.count
  end

  test 'two tasks with same name but different id are added' do
    @queue.create(name: "t1", id: "i1", action: [:blah])
    @queue.create(name: "t1", id: "i2", action: [:blah, :blah])
    assert_equal 2, @queue.count
  end

  test 'tasks with same priroity are sorted in stable order' do
    @queue.create(name: "t1", id: "i1", action: [:blah], priority: 2)
    @queue.create(name: "t2", id: "i2", action: [:blah], priority: 1)
    @queue.create(name: "t9", id: "i9", action: [:blah], priority: 2)
    @queue.create(name: "t8", id: "i8", action: [:blah], priority: 1)
    assert_equal ["i2", "i8", "i1", "i9"], @queue.task_ids
  end

  test 'tasks with same priroity are sorted by creation time' do
    @queue.create(name: "t1", id: "i1", action: [:blah], priority: 1, created: 100.5)
    @queue.create(name: "t2", id: "i2", action: [:blah], priority: 1, created: 50.5)
    assert_equal ["i2", "i1"], @queue.task_ids
  end
end
