require 'test_helper'

class BondTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  test 'is always virtual' do
    host = FactoryBot.create(:host)
    bond = FactoryBot.create(:nic_bond, :host => host)
    assert bond.virtual
    assert_valid bond

    bond = FactoryBot.create(:nic_bond, :virtual => false, :host => host)
    assert bond.virtual
  end

  test 'attached devices are stripped, case is preserved due to identifiers like on HPE Superdome Flex 280' do
    bond = FactoryBot.build_stubbed(:nic_bond, :attached_devices => 'Eth0, ETH1 ,   eth2    ')
    assert_equal "Eth0,ETH1,eth2", bond.attached_devices
  end

  test 'attached devices can be also specified as an array' do
    bond = FactoryBot.build_stubbed(:nic_bond, :attached_devices => ['Eth0', 'ETH1 ', '   eth2    '])
    assert_equal "Eth0,ETH1,eth2", bond.attached_devices
  end

  test 'attached devices interfaces can be accessed as an array' do
    bond = FactoryBot.build_stubbed(:nic_bond, :attached_devices => 'eth0,eth1,eth2')
    assert_equal %w(eth0 eth1 eth2), bond.attached_devices_identifiers
  end

  test '#add_slave adds identifier to attached_devices' do
    bond = FactoryBot.build_stubbed(:nic_bond, :attached_devices => '')
    assert bond.add_slave('eth0')
    assert_equal %w(eth0), bond.attached_devices_identifiers

    assert bond.add_slave('eth1')
    assert_equal %w(eth0 eth1), bond.attached_devices_identifiers

    assert bond.add_slave('eth0')
    assert_equal %w(eth0 eth1), bond.attached_devices_identifiers

    bond = FactoryBot.build_stubbed(:nic_bond, :attached_devices => 'eth1,eth2')
    assert bond.add_slave('eth0')
    assert_equal %w(eth1 eth2 eth0), bond.attached_devices_identifiers
  end

  test '#remove_slave remove identifier from attached_devices' do
    bond = FactoryBot.build_stubbed(:nic_bond, :attached_devices => 'eth0,eth1,eth2')
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

  test 'identifier is required for managed bonds' do
    bond = FactoryBot.build(:nic_bond, :attached_devices => 'eth0,eth1,eth2', :managed => true, :identifier => '')
    refute bond.valid?
    assert_includes bond.errors.attribute_names, :identifier
  end

  test 'identifier is not required for unmanaged bonds' do
    bond = FactoryBot.build(:nic_bond, :attached_devices => 'eth0,eth1,eth2', :managed => false, :identifier => '')
    bond.valid?
    refute_includes bond.errors.attribute_names, :identifier
  end

  context '#children_mac_addresses' do
    test 'lists mac addresses' do
      attached_devices = ['eth0', 'eth1', 'eth2']
      host = FactoryBot.create(:host)
      bond = FactoryBot.build(:nic_bond,
        :identifier => 'bond',
        :attached_devices => attached_devices.join(','))
      host.interfaces << bond
      attached_devices.each_with_index do |device, i|
        host.interfaces << FactoryBot.build(:nic_managed,
          :identifier => device,
          :mac => "00:53:67:ab:dd:0#{i}"
        )
      end
      assert_equal ['00:53:67:ab:dd:00', '00:53:67:ab:dd:01', '00:53:67:ab:dd:02'], bond.children_mac_addresses
    end
  end
end
