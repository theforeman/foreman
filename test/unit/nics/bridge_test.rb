require 'test_helper'

class BridgeTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  test 'is always virtual' do
    host = FactoryGirl.create(:host)
    bridge = FactoryGirl.build(:nic_bridge, :host => host)
    assert bridge.virtual
    assert_valid bridge

    bridge = FactoryGirl.build(:nic_bridge, :virtual => false, :host => host)
    assert bridge.virtual
  end

  test 'identifier is required for managed bridges' do
    bridge = FactoryGirl.build(:nic_bridge, :managed => true, :identifier => '')
    refute bridge.valid?
    assert_includes bridge.errors.keys, :identifier
  end

  test 'identifier is not required for unmanaged bridges' do
    bridge = FactoryGirl.build(:nic_bridge, :managed => false, :identifier => '')
    bridge.valid?
    refute_includes bridge.errors.keys, :identifier
  end
end
