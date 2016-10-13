require 'test_helper'

class Nic::BaseTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  should allow_values('00:50:56:84:4e:e3', '00:01:44:55:66:77', '72:00:03:bd:3b:70').
    for(:mac)

  should_not allow_values('13-61-f1-de-71-73', '01-00-CC-CC-DD-DD', 'ff-ff-ff-ff-ff-ff').
    for(:mac)

  test '#host_managed? returns false if interface does not have a host' do
    nic = FactoryGirl.build(:nic_base)
    nic.host = nil
    refute nic.host_managed?
  end

  test '#host_managed? returns false if associated host is unmanaged' do
    nic = FactoryGirl.build(:nic_base)
    nic.host = FactoryGirl.build(:host)
    nic.host.managed = false
    refute nic.host_managed?
  end

  test '#host_managed? returns false in non-unattended mode' do
    nic = FactoryGirl.build(:nic_base)
    nic.host = FactoryGirl.build(:host)
    nic.host.managed = true
    original, SETTINGS[:unattended] = SETTINGS[:unattended], false
    refute nic.host_managed?
    SETTINGS[:unattended] = original
  end

  test '#host_managed? return true if associated host is managed in unattended mode' do
    nic = FactoryGirl.build(:nic_base)
    nic.host = FactoryGirl.build(:host)
    nic.host.managed = true
    original, SETTINGS[:unattended] = SETTINGS[:unattended], true
    assert nic.host_managed?
    SETTINGS[:unattended] = original
  end

  test 'nic requires a host' do
    nic = FactoryGirl.build(:nic_base)
    refute nic.valid?, "Can't be valid without a host: #{nic.errors.messages}"
    assert_includes nic.errors.keys, :host
  end

  test 'nic is invalid when subnet types are wrong' do
    nic = FactoryGirl.build(:nic_base)
    subnetv4 = Subnet::Ipv4.new
    subnetv6 = Subnet::Ipv6.new

    nic.subnet = subnetv6
    nic.subnet6 = subnetv4

    refute nic.valid?, "Can't be valid with invalid subnet types: #{nic.errors.messages}"
    assert_includes nic.errors.keys, :subnet
    assert_includes nic.errors.keys, :subnet6
  end

  context 'there is already an interface with a MAC and IP' do
    let(:host) { FactoryGirl.create(:host, :managed, :with_ipv6) }

    describe 'creation of another nic with already used MAC and IP' do
      let(:nic) do
        nic = host.interfaces.build(:mac => host.mac, :managed => true, :type => 'Nic::Managed')
        nic.ip = host.ip
        nic.ip6 = host.ip6
        nic
      end

      test 'it is invalid because of conflicting mac' do
        refute nic.valid?
        assert nic.errors.has_key?(:mac)
        assert nic.errors.has_key?(:ip)
        assert nic.errors.has_key?(:ip6)
      end

      test 'it is valid if conflicting interface is on same host and is marked for destruction' do
        host.primary_interface.mark_for_destruction
        assert nic.valid?, "Nic is not valid: #{nic.errors.messages}"
      end

      test 'it is valid if conflicting interface is virtual' do
        host.primary_interface.update_attribute :virtual, true
        nic.ip = nil
        nic.ip6 = nil
        assert nic.valid?, "Nic is not valid: #{nic.errors.messages}"
      end

      test 'it is valid if conflicting interface is unmanaged' do
        host.primary_interface.update_attribute :managed, false
        nic.ip = nil
        nic.ip6 = nil
        assert nic.valid?, "Nic is not valid: #{nic.errors.messages}"
      end
    end

    describe 'creation of another nic with the same name' do
      let(:nic) { host.interfaces.build(:mac => next_mac(host.mac), :managed => true, :type => 'Nic::Managed') }

      context 'the domain is different' do
        test 'it is valid' do
          nic.name = host.shortname
          assert_nil nic.domain
          assert nic.valid?
        end
      end

      context 'the domain is the same' do
        before do
          nic.name = host.name
          nic.domain = host.domain
        end

        test 'it is invalid because of the name attribute' do
          refute nic.valid?
          assert nic.errors.has_key?(:name)
        end

        test 'it is valid if conflicting interface is on same host and is marked for destruction' do
          host.primary_interface.mark_for_destruction
          assert nic.valid?
        end
      end
    end

    describe 'creation of another nic with already used identifier' do
      let(:nic) do
        nic = host.interfaces.build(:managed => true, :type => 'Nic::Managed')
        nic.identifier = host.primary_interface.identifier
        nic
      end

      let(:nic2) do
        host.interfaces.build(:managed => true, :type => 'Nic::Managed')
      end

      test 'it is invalid because of conflicting identifier' do
        refute nic.valid?
        assert nic.errors.has_key?(:identifier)
      end

      test 'it ignores empty identifiers' do
        nic.mac = '00:11:11:22:22:33'
        nic2.mac = '00:11:11:22:22:34'
        nic.identifier = nic2.identifier = ''
        nic.save
        # nic2.save

        assert nic.valid?
        assert nic2.valid?
      end
    end
  end
end
