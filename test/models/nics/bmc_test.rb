require 'test_helper'

class BMCTest < ActiveSupport::TestCase
  test 'lowercase IPMI provider string gets set to uppercase' do
    host = FactoryBot.build_stubbed(:host, :managed)
    assert FactoryBot.build_stubbed(:nic_bmc, :host => host, :provider => 'IPMI', :subnet => subnets(:one)).valid?
  end

  test 'BMC IPMI availability' do
    host = FactoryBot.build_stubbed(:host, :managed)
    nic = FactoryBot.build_stubbed(:nic_bmc, :host => host, :provider => 'IPMI', :username => "user", :password => "pass", :subnet => subnets(:one))
    host.expects(:bmc_nic).returns(nic)
    assert host.bmc_available?
  end

  test 'BMC SSH availability' do
    host = FactoryBot.build_stubbed(:host, :managed)
    nic = FactoryBot.build_stubbed(:nic_bmc, :host => host, :provider => 'SSH', :subnet => subnets(:one))
    host.expects(:bmc_nic).returns(nic)
    assert host.bmc_available?
  end

  test 'upcasing provider does not fail if provider is not present' do
    host = FactoryBot.build_stubbed(:host, :managed)
    assert_nothing_raised do
      FactoryBot.build_stubbed(:nic_bmc, :host => host, :provider => nil, :subnet => subnets(:one)).valid?
    end
  end

  context "bmc password encryption" do
    def setup
      host = FactoryBot.build(:host, :managed)
      @bmc_nic = FactoryBot.build(:nic_bmc, :with_subnet, :host => host, :subnet => subnets(:one))
      @bmc_nic.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
      @bmc_nic.expects(:validate_bmc_proxy).at_least_once.returns(true)
      @bmc_nic.save
    end

    test 'BMC password is encrypted in DB' do
      assert @bmc_nic.password_in_db.include? Encryptable::ENCRYPTION_PREFIX
    end

    test 'BMC password is decrypted in ENC' do
      bmc_nic_enc = @bmc_nic.to_export
      assert_equal bmc_nic_enc['password'], 'admin'
    end
  end

  test 'BMC password is provided in #password' do
    bmc_nic = FactoryBot.build_stubbed(:nic_bmc, :provider => 'IPMI', :password => 'secret', :subnet => subnets(:one))
    assert_equal 'secret', bmc_nic.password
  end

  context 'with bmc_credentials_accessible => false' do
    setup do
      Setting[:bmc_credentials_accessible] = false
      host = FactoryBot.build(:host, :managed)
      @bmc_nic = FactoryBot.build_stubbed(:nic_bmc, :host => host, :provider => 'IPMI', :username => "user", :password => 'secret', :subnet => subnets(:one))
    end

    test 'BMC password is redacted in ENC output' do
      assert_nil @bmc_nic.to_export['password']
    end

    test 'BMC password is hidden in #password' do
      assert_nil @bmc_nic.password
      assert_equal 'secret', @bmc_nic.password_unredacted
    end

    test '#proxy instantiates ProxyAPI with password' do
      @bmc_nic.expects(:bmc_proxy).returns(FactoryBot.create(:bmc_smart_proxy))
      ProxyAPI::BMC.expects(:new).with(has_entry(:password => 'secret'))
      @bmc_nic.proxy
    end

    test 'the host still can find an useful BMC interface' do
      @bmc_nic.host.expects(:bmc_nic).returns(@bmc_nic)
      assert_equal true, @bmc_nic.host.bmc_available?
    end
  end

  context "no BMC smart proxy exists" do
    def setup
      SmartProxy.with_features('BMC').destroy_all
    end

    test 'requires BMC proxy without subnet' do
      host = FactoryBot.build_stubbed(:host, :managed)
      bmc_nic = FactoryBot.build(:nic_bmc, :host => host, :subnet => subnets(:one))
      host.interfaces << bmc_nic
      refute_with_errors bmc_nic.valid?, bmc_nic, :type, /There is no proxy with BMC/
    end

    test 'requires BMC proxy in the same subnet' do
      host = FactoryBot.build_stubbed(:host, :managed)
      bmc_nic = FactoryBot.build(:nic_bmc, :with_subnet, :host => host, :subnet => subnets(:one))
      host.interfaces << bmc_nic
      refute_with_errors bmc_nic.valid?, bmc_nic, :type, /There is no proxy with BMC/
    end

    test 'BMC proxy not required, if NIC is not managed' do
      host = FactoryBot.build(:host, :managed)
      bmc_nic = FactoryBot.build(:nic_bmc, :managed => false, :subnet => subnets(:one))
      host.interfaces << bmc_nic
      assert bmc_nic.valid?
    end

    test 'BMC proxy not required, if host is not managed' do
      host = FactoryBot.build(:host, :managed => false)
      bmc_nic = FactoryBot.build(:nic_bmc, :host => host, :subnet => subnets(:one))
      host.interfaces << bmc_nic
      assert bmc_nic.valid?
    end
  end
end
