require 'test_helper'

module Host
  class BaseTest < ActiveSupport::TestCase
    include FactImporterIsolation

    should validate_presence_of(:name)
    allow_transactions_for_any_importer

    context "with new host" do
      subject { Host::Base.new(:name => 'test') }
      should validate_uniqueness_of(:name).case_insensitive
    end
    should_not allow_value('hostname_with_dashes').for(:name)
    should allow_value('hostname.with.periods').for(:name)

    test "should generate a random name" do
      NameGenerator.any_instance.expects(:next_random_name).returns("some-name")
      host = Host::Base.new(:domain => FactoryBot.create(:domain, :name => "domain.net"))
      host.valid?
      assert_equal "some-name.domain.net", host.name
    end

    test "should make hostname lowercase" do
      host = Host::Base.new(:name => 'MYHOST',
                            :domain => FactoryBot.create(:domain, :name => "mydomainlowercase.net"))
      host.valid?
      assert_equal "myhost.mydomainlowercase.net", host.name
    end

    test "should update name when domain is changed" do
      host = Host::Base.new(:name => 'foo')
      refute_equal "#{host.shortname}.yourdomain.net", host.name
      host.domain_name = "yourdomain.net"
      host.save!
      assert_equal "#{host.shortname}.yourdomain.net", host.name
    end

    test '.new should build host with primary interface' do
      host = Host::Base.new
      assert host.primary_interface
      assert_equal 1, host.interfaces.size
    end

    test '.new should mark one interfaces as primary if none was chosen explicitly' do
      host = Host::Base.new(:interfaces_attributes => [{:ip => '192.168.0.1' }, { :ip => '192.168.1.2' }])
      assert host.primary_interface
      assert_equal 2, host.interfaces.size
    end

    test '.new does not reset primary flag if it was set explicitly' do
      host = Host::Base.new(:interfaces_attributes => [{:ip => '192.168.0.1' }, { :ip => '192.168.1.2', :primary => true }])
      assert_equal 2, host.interfaces.size
      assert_equal '192.168.1.2', host.primary_interface.ip
    end

    test "host should not save without primary interface" do
      host = Host::Base.new(:name => 'foo')
      host.interfaces = []
      refute host.valid?
      assert_includes host.errors.keys, :interfaces

      host.interfaces = [FactoryBot.build_stubbed(:nic_managed, :primary => true, :host => host,
                                            :domain => FactoryBot.create(:domain))]
      assert host.valid?
    end

    test '.dup should return host with primary interface' do
      host = Host::Base.new.dup
      assert host.primary_interface
      assert_equal 1, host.interfaces.size
    end

    test 'shortname periods check considers domain outside taxonomy scope' do
      host_org = FactoryBot.create(:organization)
      other_org = FactoryBot.create(:organization)

      domain = FactoryBot.create(:domain, organizations: [other_org])
      refute domain.organizations.include?(host_org)

      host = FactoryBot.create(:host, organization: host_org, domain_id: domain.id)
      host = Host.find(host.id)
      assert host.valid?
    end

    test "should not update an interface" do
      nic = FactoryBot.build(:nic_primary_and_provision)
      assert_nil nic.subnet
      assert_nil nic.subnet6
      nic.ip = '2.3.4.5'
      nic.ip6 = '2001:db10:7::6'
      Setting[:update_subnets_from_facts] = "none"
      Host::Managed.new.send(:update_subnet_from_facts, nic, false)
      assert_nil nic.subnet
      assert_nil nic.subnet6
    end

    test "should not update an interface when we want to keep it" do
      nic = FactoryBot.build(:nic_primary_and_provision)
      assert_nil nic.subnet
      assert_nil nic.subnet6
      nic.ip = '2.3.4.5'
      nic.ip6 = '2001:db10:7::6'
      Setting[:update_subnets_from_facts] = "all"
      Host::Managed.new.send(:update_subnet_from_facts, nic, true)
      assert_nil nic.subnet
      assert_nil nic.subnet6
    end

    test "should update only provisioning interface" do
      nic = FactoryBot.build(:nic_managed, :primary => true)
      assert_nil nic.subnet
      assert_nil nic.subnet6
      nic.ip = '2.3.4.5'

      Setting[:update_subnets_from_facts] = "provision"
      Host::Managed.new.send(:update_subnet_from_facts, nic, false)
      assert_nil nic.subnet
      assert_nil nic.subnet6

      provision = FactoryBot.build(:nic_primary_and_provision)
      assert_nil provision.subnet
      assert_nil provision.subnet6
      provision.ip = '2.3.4.5'
      provision.ip6 = '2001:db10:7::6'
      Host::Managed.new.send(:update_subnet_from_facts, provision, false)
      assert_equal subnets(:one), provision.subnet
      assert_equal subnets(:seven), provision.subnet6
    end

    test "should update any interface" do
      nic = FactoryBot.build(:nic_managed, :primary => true)
      assert_nil nic.subnet
      assert_nil nic.subnet6
      nic.ip = '2.3.4.5'
      nic.ip6 = '2001:db10:7::6'

      Setting[:update_subnets_from_facts] = "all"
      Host::Managed.new.send(:update_subnet_from_facts, nic, false)
      assert_equal subnets(:one), nic.subnet
      assert_equal subnets(:seven), nic.subnet6
    end
  end
end
