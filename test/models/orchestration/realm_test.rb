require 'test_helper'

class RealmOrchestrationTest < ActiveSupport::TestCase
  setup :disable_orchestration

  def test_hostgroup_change_triggers_update
    host = FactoryGirl.create(:host, :managed, :with_realm)
    host.queue.expects(:create).with(has_entries(:action => [host, :update_realm])).returns({})
    host.hostgroup = FactoryGirl.create(:hostgroup)
    assert host.save
  end

  def test_host_realm_change_triggers_update
    host = FactoryGirl.create(:host, :managed)
    host.queue.expects(:create).with(has_entries(:action => [host, :update_realm])).returns({})
    host.realm = FactoryGirl.create(:realm)
    assert host.save
  end
end
