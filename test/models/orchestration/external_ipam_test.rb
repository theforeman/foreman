require 'test_helper'

class ExternalIPAMOrchestrationTest < ActiveSupport::TestCase
  let(:ipam_proxy) do
    FactoryBot.create(:smart_proxy,
      :features => [FactoryBot.create(:feature, :name => :external_ipam)])
  end

  context 'host with interface using external ipam' do
    let(:subnet) do
      FactoryBot.create(:subnet,
        :ipam => "External IPAM",
        :network => '100.25.25.0',
        :mask => '255.255.255.0',
        :external_ipam => ipam_proxy)
    end

    let(:interfaces) do
      [FactoryBot.build(:nic_managed,
        :ip => '100.25.25.1',
        :mac => '00:53:67:ab:dd:00',
        :subnet => subnet,
        :domain => FactoryBot.create(:domain))]
    end

    test "host should be valid" do
      host = FactoryBot.create(:host, :managed, :interfaces => interfaces)
      assert host.valid?
    end

    test "should queue a create task when new host created" do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      assert host.new_record?
      assert host.valid?
      host.save
      assert_equal ["external_ipam_create_00:53:67:ab:dd:00"], host.queue.task_ids
      assert_equal :set_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00").action.last
    end

    test "should queue a remove task when host is destroyed" do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.destroy
      assert_equal ["external_ipam_remove_00:53:67:ab:dd:00"], host.queue.task_ids
      assert_equal :remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00").action.last
    end

    test 'should queue an update task when interface ip is updated in host' do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.interfaces.first.ip = '100.25.25.2'
      host.save!
      assert_equal ["external_ipam_remove_00:53:67:ab:dd:00", "external_ipam_create_00:53:67:ab:dd:00"], host.queue.task_ids
      assert_equal :remove_external_ip, host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00").action.last
      assert_equal :set_external_ip, host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00").action.last
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
      assert_not_equal ["external_ipam_create_00:53:67:ab:dd:00"], host.queue.task_ids
      assert_nil host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00")
    end

    test "should not queue an external ipam remove task when host is destroyed" do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.destroy
      assert_not_equal ["external_ipam_remove_00:53:67:ab:dd:00"], host.queue.task_ids
      assert_nil host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00")
    end

    test 'should not queue an external ipam update task when interface ip is updated in host' do
      host = FactoryBot.build(:host, :managed, :interfaces => interfaces)
      host.save
      host.queue.clear
      host.interfaces.first.ip = '100.25.25.2'
      host.save!
      assert_not_equal ["external_ipam_remove_00:53:67:ab:dd:00", "external_ipam_create_00:53:67:ab:dd:00"], host.queue.task_ids
      assert_nil host.queue.find_by_id("external_ipam_remove_00:53:67:ab:dd:00")
      assert_nil host.queue.find_by_id("external_ipam_create_00:53:67:ab:dd:00")
    end
  end
end
