require 'test_helper'

class BMCTest < ActiveSupport::TestCase
  test 'lowercase IPMI provider string gets set to uppercase' do
    host = FactoryGirl.build(:host, :managed)
    assert FactoryGirl.build(:nic_bmc, :host => host, :provider => 'ipmi').valid?
  end

  context "no BMC smart proxy exists" do
    def setup
      SmartProxy.with_features('BMC').destroy_all
    end

    test 'requires BMC proxy without subnet' do
      host = FactoryGirl.build(:host, :managed)
      bmc_nic = FactoryGirl.build(:nic_bmc, :host => host)
      host.interfaces << bmc_nic
      refute_with_errors bmc_nic.valid?, bmc_nic, :type, /no proxy/
    end

    test 'requires BMC proxy in the same subnet' do
      host = FactoryGirl.build(:host, :managed)
      bmc_nic = FactoryGirl.build(:nic_bmc, :with_subnet, :host => host)
      host.interfaces << bmc_nic
      refute_with_errors bmc_nic.valid?, bmc_nic, :type, /no proxy/
    end

    test 'BMC proxy not required, if NIC is not managed' do
      host = FactoryGirl.build(:host, :managed)
      bmc_nic = FactoryGirl.build(:nic_bmc, :managed => false)
      host.interfaces << bmc_nic
      assert bmc_nic.valid?
    end

    test 'BMC proxy not required, if host is not managed' do
      host = FactoryGirl.build(:host, :managed => false)
      bmc_nic = FactoryGirl.build(:nic_bmc, :host => host)
      host.interfaces << bmc_nic
      assert bmc_nic.valid?
    end
  end
end
