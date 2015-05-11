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
end
