require 'test_helper'

class BondTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  test 'is always virtual' do
    host = FactoryGirl.create(:host)
    bond = FactoryGirl.create(:nic_bond, :host => host)
    assert bond.virtual
    assert_valid bond

    bond = FactoryGirl.create(:nic_bond, :virtual => false, :host => host)
    assert bond.virtual
  end

  test 'attached devices are stripped and downcased' do
    bond = FactoryGirl.build(:nic_bond, :attached_devices => 'Eth0, ETH1 ,   eth2    ')
    assert_equal "eth0,eth1,eth2", bond.attached_devices
  end

  test 'attached devices can be also specified as an array' do
    bond = FactoryGirl.build(:nic_bond, :attached_devices => ['Eth0', 'ETH1 ','   eth2    '])
    assert_equal "eth0,eth1,eth2", bond.attached_devices
  end

  test 'attached devices interfaces can be accessed as an array' do
    bond = FactoryGirl.build(:nic_bond, :attached_devices => 'eth0,eth1,eth2')
    assert_equal %w(eth0 eth1 eth2), bond.attached_devices_identifiers
  end

  test '#add_slave adds identifier to attached_devices' do
    bond = FactoryGirl.build(:nic_bond, :attached_devices => '')
    assert bond.add_slave('eth0')
    assert_equal %w(eth0), bond.attached_devices_identifiers

    assert bond.add_slave('eth1')
    assert_equal %w(eth0 eth1), bond.attached_devices_identifiers

    assert bond.add_slave('eth0')
    assert_equal %w(eth0 eth1), bond.attached_devices_identifiers

    bond = FactoryGirl.build(:nic_bond, :attached_devices => 'eth1,eth2')
    assert bond.add_slave('eth0')
    assert_equal %w(eth1 eth2 eth0), bond.attached_devices_identifiers
  end

  test '#remove_slave remove identifier from attached_devices' do
    bond = FactoryGirl.build(:nic_bond, :attached_devices => 'eth0,eth1,eth2')
    assert bond.remove_slave('eth1')
    assert_equal %w(eth0 eth2), bond.attached_devices_identifiers
    assert bond.remove_slave('eth8')
    assert_equal %w(eth0 eth2), bond.attached_devices_identifiers

    assert bond.remove_slave('eth0')
    assert_equal %w(eth2), bond.attached_devices_identifiers

    assert bond.remove_slave('eth2')
    assert_equal [], bond.attached_devices_identifiers

    assert bond.remove_slave('eth2')
    assert_equal [], bond.attached_devices_identifiers
  end
end
