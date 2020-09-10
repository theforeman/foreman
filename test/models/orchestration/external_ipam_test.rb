require 'test_helper'

class ExternalIPAMOrchestrationTest < ActiveSupport::TestCase
  let(:ipam_proxy) do
    FactoryBot.create(:smart_proxy,
      :features => [FactoryBot.create(:feature, :name => 'External IPAM')])
  end

  context 'host with IPv4 interface using external ipam' do
    let(:subnet) do
      FactoryBot.create(:subnet,
        :ipam => IPAM::MODES[:external_ipam],
        :network => '100.25.25.0',
        :mask => '255.255.255.0',
        :externalipam => ipam_proxy)
    end

    let(:interfaces) do
      [FactoryBot.build(:nic_managed,
        :ip => '100.25.25.1',
        :mac => '00:53:67:ab:dd:00',
        :subnet => subnet,
        :domain => FactoryBot.create(:domain))]
    end

    test "host with IPv4 interface should be valid" do
      host = FactoryBot.create(:host, :managed, :interfaces => interfaces)
      assert host.valid?
    end

    test "should queue a create task when new host created" do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      assert host.new_record?
      assert host.valid?
      host.save
      assert_equal ["external_ipam_create_00:53:67:ab:dd:00_IPv4"], host.queue.task_ids
      assert_equal :set_add_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv4").action[-2].to_sym
    end

    test "should queue a remove task when host is destroyed" do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.destroy
      assert_equal ["external_ipam_remove_00:53:67:ab:dd:00_IPv4"], host.queue.task_ids
      assert_equal :set_remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv4").action[-2].to_sym
    end

    test 'should queue an update task when interface ip is updated in host' do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.interfaces.first.ip = '100.25.25.2'
      host.save!
      assert_equal ["external_ipam_remove_00:53:67:ab:dd:00_IPv4", "external_ipam_create_00:53:67:ab:dd:00_IPv4"], host.queue.task_ids
      assert_equal :set_remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv4").action[-2].to_sym
      assert_equal :set_add_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv4").action[-2].to_sym
    end
  end

  context 'host with IPv6 interface using external ipam' do
    let(:subnet) do
      FactoryBot.create(:subnet_ipv6,
        :ipam => IPAM::MODES[:external_ipam],
        :network => '2001:db8::',
        :cidr => "64",
        :externalipam => ipam_proxy)
    end

    let(:interfaces) do
      [FactoryBot.build(:nic_managed,
        :ip6 => '2001:db8::1',
        :mac => '00:53:67:ab:dd:00',
        :subnet6 => subnet,
        :domain => FactoryBot.create(:domain))]
    end

    test "host with IPv6 interface should be valid" do
      host = FactoryBot.create(:host, :managed, :interfaces => interfaces)
      assert host.valid?
    end

    test "should queue a create task when new host created" do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      assert host.new_record?
      assert host.valid?
      host.save
      assert_equal ["external_ipam_create_00:53:67:ab:dd:00_IPv6"], host.queue.task_ids
      assert_equal :set_add_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv6").action[-2].to_sym
    end

    test "should queue a remove task when host is destroyed" do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.destroy
      assert_equal ["external_ipam_remove_00:53:67:ab:dd:00_IPv6"], host.queue.task_ids
      assert_equal :set_remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv6").action[-2].to_sym
    end

    test 'should queue an update task when interface ip is updated in host' do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.interfaces.first.ip6 = '2001:db8::2'
      host.save!
      assert_equal ["external_ipam_remove_00:53:67:ab:dd:00_IPv6", "external_ipam_create_00:53:67:ab:dd:00_IPv6"], host.queue.task_ids
      assert_equal :set_remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv6").action[-2].to_sym
      assert_equal :set_add_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv6").action[-2].to_sym
    end
  end

  context 'host with dual stack interface(IPv4 & IPv6) using external ipam' do
    let(:subnet) do
      FactoryBot.create(:subnet,
        :ipam => IPAM::MODES[:external_ipam],
        :network => '100.25.25.0',
        :mask => '255.255.255.0',
        :externalipam => ipam_proxy)
    end

    let(:subnet6) do
      FactoryBot.create(:subnet_ipv6,
        :ipam => IPAM::MODES[:external_ipam],
        :network => '2001:db8::',
        :cidr => "64",
        :externalipam => ipam_proxy)
    end

    let(:interfaces) do
      [FactoryBot.build(:nic_managed,
        :ip => '100.25.25.1',
        :ip6 => '2001:db8::1',
        :mac => '00:53:67:ab:dd:00',
        :subnet => subnet,
        :subnet6 => subnet6,
        :domain => FactoryBot.create(:domain))]
    end

    test "host with dual stack interface should be valid" do
      host = FactoryBot.create(:host, :managed, :interfaces => interfaces)
      assert host.valid?
    end

    test "should queue 2 create tasks when new host created" do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      assert host.new_record?
      assert host.valid?
      host.save
      assert_equal ["external_ipam_create_00:53:67:ab:dd:00_IPv4", "external_ipam_create_00:53:67:ab:dd:00_IPv6"], host.queue.task_ids
      assert_equal :set_add_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv4").action[-2].to_sym
      assert_equal :set_add_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv6").action[-2].to_sym
    end

    test "should queue 2 remove tasks when host is destroyed" do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.destroy
      assert_equal ["external_ipam_remove_00:53:67:ab:dd:00_IPv4", "external_ipam_remove_00:53:67:ab:dd:00_IPv6"], host.queue.task_ids
      assert_equal :set_remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv4").action[-2].to_sym
      assert_equal :set_remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv6").action[-2].to_sym
    end

    test 'should queue 2 update tasks when both ips in dual stack interface are updated on host' do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.interfaces.first.ip = '100.25.25.2'
      host.interfaces.first.ip6 = '2001:db8::2'
      host.save!
      assert_equal ["external_ipam_remove_00:53:67:ab:dd:00_IPv4", "external_ipam_remove_00:53:67:ab:dd:00_IPv6", "external_ipam_create_00:53:67:ab:dd:00_IPv4", "external_ipam_create_00:53:67:ab:dd:00_IPv6"], host.queue.task_ids
      assert_equal :set_remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv4").action[-2].to_sym
      assert_equal :set_add_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv4").action[-2].to_sym
      assert_equal :set_remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv6").action[-2].to_sym
      assert_equal :set_add_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv6").action[-2].to_sym
    end

    test 'should queue only 1 update tasks when IPv4 address in dual stack interface is updated on host' do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.interfaces.first.ip = '100.25.25.2'
      host.save!
      assert_equal ["external_ipam_remove_00:53:67:ab:dd:00_IPv4", "external_ipam_create_00:53:67:ab:dd:00_IPv4"], host.queue.task_ids
      assert_equal :set_remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv4").action[-2].to_sym
      assert_equal :set_add_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv4").action[-2].to_sym
    end

    test 'should queue only 1 update tasks when IPv6 address in dual stack interface is updated on host' do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.interfaces.first.ip6 = '2001:db8::2'
      host.save!
      assert_equal ["external_ipam_remove_00:53:67:ab:dd:00_IPv6", "external_ipam_create_00:53:67:ab:dd:00_IPv6"], host.queue.task_ids
      assert_equal :set_remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv6").action[-2].to_sym
      assert_equal :set_add_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv6").action[-2].to_sym
    end
  end

  context 'host with interface not using external ipam' do
    let(:subnet) do
      FactoryBot.create(:subnet,
        :ipam => "None",
        :network => '100.25.25.0',
        :mask => '255.255.255.0')
    end

    let(:interfaces) do
      [FactoryBot.build(:nic_managed,
        :ip => '100.25.25.1',
        :mac => '00:53:67:ab:dd:00',
        :subnet => subnet,
        :domain => FactoryBot.create(:domain))]
    end

    test "should not queue an external ipam create task when new host created" do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      assert host.new_record?
      assert host.valid?
      host.save
      assert_not_equal ["external_ipam_create_00:53:67:ab:dd:00_IPv4"], host.queue.task_ids
      assert_nil host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv4")
    end

    test "should not queue an external ipam remove task when host is destroyed" do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.destroy
      assert_not_equal ["external_ipam_remove_00:53:67:ab:dd:00_IPv4"], host.queue.task_ids
      assert_nil host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv4")
    end

    test 'should not queue an external ipam update task when interface ip is updated in host' do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.interfaces.first.ip = '100.25.25.2'
      host.save!
      assert_not_equal ["external_ipam_remove_00:53:67:ab:dd:00_IPv4", "external_ipam_create_00:53:67:ab:dd:00_IPv4"], host.queue.task_ids
      assert_nil host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00_IPv4")
      assert_nil host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00_IPv4")
    end
  end
end
