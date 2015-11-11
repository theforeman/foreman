require 'test_helper'

class NicBaseTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

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

  context 'there is already an interface with a MAC and IP' do
    let(:host) { FactoryGirl.create(:host, :managed) }

    describe 'creation of another nic with already used MAC and IP' do
      let(:nic) do
        nic = host.interfaces.build(:mac => host.mac, :managed => true, :type => 'Nic::Managed')
        nic.ip = host.ip
        nic
      end

      test 'it is invalid because of conflicting mac' do
        refute nic.valid?
        assert nic.errors.has_key?(:mac)
        assert nic.errors.has_key?(:ip)
      end

      test 'it is valid if conflicting interface is on same host and is marked for destruction' do
        host.primary_interface.mark_for_destruction
        assert nic.valid?
      end

      test 'it is valid if conflicting interface is virtual' do
        host.primary_interface.update_attribute :virtual, true
        nic.ip = nil
        assert nic.valid?
      end

      test 'it is valid if conflicting interface is unmanaged' do
        host.primary_interface.update_attribute :managed, false
        nic.ip = nil
        assert nic.valid?
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

      test 'it is invalid because of conflicting identifier' do
        refute nic.valid?
        assert nic.errors.has_key?(:identifier)
      end
    end
  end
end
