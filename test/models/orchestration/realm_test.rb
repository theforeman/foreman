require 'test_helper'

class RealmOrchestrationTest < ActiveSupport::TestCase
  setup :disable_orchestration

  test 'host without realm does not queue realm create' do
    host = FactoryBot.build(:host, :managed)
    assert_valid host
    tasks = host.queue.all.map(&:name)
    assert_equal 0, tasks.size
  end

  test 'host without realm change does not queue realm delete and create' do
    host = FactoryBot.create(:host, :managed, :with_realm)
    host.queue.clear
    host.save!
    tasks = host.queue.all.map(&:name)
    assert_equal 0, tasks.size
  end

  test 'host with realm queues realm create' do
    host = FactoryBot.build(:host, :managed, :with_realm)
    assert_valid host
    tasks = host.queue.all.map(&:name)
    assert_includes tasks, "Create realm entry for #{host}"
    assert_equal 1, tasks.size
  end

  test 'hostgroup change triggers realm update' do
    host = FactoryBot.create(:host, :managed, :with_realm)
    host.queue.expects(:create).with(has_entries(:action => [host, :update_realm])).returns({})
    host.hostgroup = FactoryBot.create(:hostgroup)
    assert host.save
  end

  test 'host realm change triggers realm create' do
    host = FactoryBot.create(:host, :managed)
    host.queue.expects(:create).with(has_entries(:action => [host, :set_realm])).returns({})
    host.realm = FactoryBot.create(:realm)
    assert host.save
  end

  test 'host realm removal queues realm delete' do
    host = FactoryBot.create(:host, :managed, :with_realm)
    host.queue.clear
    host.realm = nil
    assert_valid host
    tasks = host.queue.all.map(&:name)
    assert_includes tasks, "Delete realm entry for #{host}"
    assert_equal 1, tasks.size
  end

  test 'host realm change to other realm queues realm delete and create' do
    host = FactoryBot.create(:host, :managed, :with_realm)
    host.queue.clear
    host.realm = FactoryBot.create(:realm)
    assert_valid host
    tasks = host.queue.all.map(&:name)
    assert_includes tasks, "Delete realm entry for #{host}"
    assert_includes tasks, "Create realm entry for #{host}"
    assert_equal 2, tasks.size
  end
end
