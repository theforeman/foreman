require 'test_helper'

class ComputeOrchestrationTest < ActiveSupport::TestCase
  describe 'compute details' do
    setup do
      @cr = FactoryBot.build_stubbed(:libvirt_cr)
      @host = FactoryBot.build_stubbed(:host, :compute_resource => @cr)
      @host.vm = mock("vm")
    end

    test "are set for CR providing MAC" do
      @host.expects(:match_macs_to_nics).returns(true)
      @cr.stubs(:provided_attributes).returns({:mac => :mac})
      assert(@host.send(:setComputeDetails))
    end

    test "are set for CR providing IP" do
      an_ip = '1.2.3.4'
      @cr.stubs(:provided_attributes).returns({:ip => :ip})
      @host.vm.expects(:ip).returns(an_ip)
      assert @host.send(:setComputeDetails), "Failed to setComputeDetails, errors: #{@host.errors.full_messages}"
      assert_equal an_ip, @host.ip
    end

    test "are set for CR providing IP via find_addresses" do
      an_ip = '1.2.3.4'
      @cr.stubs(:provided_attributes).returns({:ip => :ip})
      @host.vm.stubs(:ip_addresses).returns([an_ip])
      @host.vm.expects(:ip).returns(nil)
      @host.expects(:ssh_open?).at_least_once.with(an_ip).returns(true)
      @host.stubs(:compute_attributes).returns({})
      assert @host.send(:setComputeDetails), "Failed to setComputeDetails, errors: #{@host.errors.full_messages}"
      assert_equal an_ip, @host.ip
    end

    test "are set for CR providing IPv6" do
      an_ip6 = '2001:db8::1'
      @cr.stubs(:provided_attributes).returns({:ip6 => :ip6})
      @host.vm.expects(:ip6).returns(an_ip6)
      assert @host.send(:setComputeDetails), "Failed to setComputeDetails, errors: #{@host.errors.full_messages}"
      assert_equal an_ip6, @host.ip6
    end

    test "are set for CR returning a blank value for ip6 while claiming to provide ip4 + ip6" do
      # Create a host with ip6 = nil to test that validate_foreman_attr does not detect a duplicate ip
      FactoryBot.create(:host)

      an_ip = '1.2.3.4'
      @cr.stubs(:provided_attributes).returns({:ip => :ip, :ip6 => :ip6})
      @host.vm.stubs(:ip_addresses).returns([an_ip])
      @host.vm.expects(:ip).returns(an_ip)
      @host.vm.expects(:ip6).returns(nil)
      assert @host.send(:setComputeDetails), "Failed to setComputeDetails, errors: #{@host.errors.full_messages}"
      assert_equal an_ip, @host.ip
      assert_nil @host.ip6
    end

    test "are set for CR providing an unknown attribute" do
      a_value = 'value'
      @cr.stubs(:provided_attributes).returns({:attr => :attr})
      @host.vm.expects(:attr).returns(a_value)
      @host.expects(:attr=).returns(a_value)
      @host.expects(:validate_foreman_attr).returns(true)
      assert(@host.send(:setComputeDetails))
    end
  end

  describe 'compute' do
    let(:compute_resource) do
      FactoryBot.build(:libvirt_cr)
    end

    let(:host) do
      FactoryBot.build(:host, compute_resource: compute_resource, compute_attributes: {})
    end

    test "creates vm successfully" do
      compute_resource.stubs(:create_vm).returns(true).once
      assert host.send(:setCompute)
    end

    test "alerts user when compute attributes are not set" do
      host.compute_attributes = nil
      host.expects(:log_failure).once
      refute host.send(:setCompute)
    end

    test "logs a failure when creating vm throws exception" do
      compute_resource.stubs(:create_vm).raises(Fog::Errors::Error).once
      host.expects(:log_failure).once
      host.compute_attributes = {}
      refute host.send(:setCompute)
    end
  end

  test "if MAC is changed, dhcp_record cache is dropped" do
    cr = FactoryBot.build_stubbed(:libvirt_cr)
    cr.stubs(:provided_attributes).returns({:mac => :mac})
    host = FactoryBot.build_stubbed(:host, :managed, :compute_resource => cr)
    host.vm = mock("vm")
    fog_nic = OpenStruct.new(:mac => '00:00:00:00:01')
    host.vm.expects(:interfaces).returns([fog_nic])
    host.vm.expects(:select_nic).returns(fog_nic)
    host.primary_interface.name = 'something'
    host.primary_interface.mac = '00:00:00:00:00:02'
    host.primary_interface.subnet = FactoryBot.build_stubbed(:subnet, :dhcp, :network => '255.255.255.0')
    host.operatingsystem = FactoryBot.build_stubbed(:operatingsystem)

    refute_nil host.primary_interface.dhcp_records
    original = host.primary_interface.dhcp_records.map(&:object_id)
    host.send :match_macs_to_nics, :mac
    new = host.primary_interface.dhcp_records.map(&:object_id)
    refute_equal original, new
    assert_equal '00:00:00:00:01', host.primary_interface.mac
  end

  test "a helpful error message shows up if no user_data is provided and it's necessary" do
    image = images(:one)
    host = FactoryBot.build_stubbed(:host, :operatingsystem => image.operatingsystem, :image => image,
                                    :compute_resource => image.compute_resource)
    host.send(:setUserData)
    assert host.errors.full_messages.first =~ /associate it/
  end

  test "rolling back userdata after it is set, deletes the attribute" do
    image = images(:one)
    host = FactoryBot.build_stubbed(:host, :operatingsystem => image.operatingsystem, :image => image,
                             :compute_resource => image.compute_resource)
    prov_temp = FactoryBot.create(:provisioning_template, :template_kind => TemplateKind.create(:name => "user_data"))
    host.stubs(:provisioning_template).returns(prov_temp)
    attrs = {}
    host.stubs(:compute_attributes).returns(attrs)
    host.send(:setUserData)
    assert_equal true, host.compute_attributes.key?(:user_data)
    host.send(:delUserData)
    assert_equal false, host.compute_attributes.key?(:user_data)
  end

  describe 'only physical interfaces are matched' do
    setup do
      @cr = FactoryBot.build(:libvirt_cr)
      @cr.stubs(:provided_attributes).returns({:mac => :mac})
      @physical = FactoryBot.build(:nic_base, :virtual => false)
      @virtual = FactoryBot.build(:nic_base, :virtual => true)

      @host = FactoryBot.build(:host,
        :compute_resource => @cr)
      @host.interfaces = [@virtual, @physical]
      @host.vm = mock("vm")
      @host.vm.stubs(:interfaces).returns([])
    end

    test 'matching fog attributes only for physical interfaces' do
      @host.vm.expects(:select_nic).once.returns(OpenStruct.new)
      @host.vm.expects(:select_nic).never.with([], @virtual).returns(OpenStruct.new)
      @host.stubs(:validate_foreman_attr).returns(true)
      @host.send(:match_macs_to_nics, :nic_attrs)
    end
  end

  describe "error message for NICs that can't be matched with those on virtual machine" do
    def host_for_nic_orchestration(nic)
      cr = FactoryBot.build_stubbed(:vmware_cr)
      cr.stubs(:provided_attributes).returns({:mac => :mac})

      host = FactoryBot.build_stubbed(:host, :interfaces => [nic], :compute_resource => cr)
      host.vm = mock("vm")
      host.vm.stubs(:interfaces).returns([])
      host.vm.stubs(:select_nic).returns(nil)
      host
    end

    def expected_message(identifier)
      "Could not find virtual machine network interface matching #{identifier}"
    end

    test "it adds message with NIC identifier" do
      nic = FactoryBot.build_stubbed(:nic_primary_and_provision, :name => 'test')
      host = host_for_nic_orchestration(nic)
      host.send(:setComputeDetails)
      assert_equal expected_message(nic.identifier), host.errors.full_messages.first
    end

    test "it adds message with NIC ip" do
      nic = FactoryBot.build_stubbed(:nic_primary_and_provision, :name => 'test', :identifier => '')
      host = host_for_nic_orchestration(nic)
      host.send(:setComputeDetails)
      assert_equal expected_message(nic.ip), host.errors.full_messages.first
    end

    test "it adds message with NIC name" do
      nic = FactoryBot.build_stubbed(:nic_primary_and_provision, :name => 'test', :identifier => nil, :ip => '')
      host = host_for_nic_orchestration(nic)
      host.send(:setComputeDetails)
      assert_equal expected_message(nic.name), host.errors.full_messages.first
    end

    test "it adds message with NIC type" do
      nic = FactoryBot.build_stubbed(:nic_primary_and_provision, :name => '', :identifier => nil, :ip => nil)
      host = host_for_nic_orchestration(nic)
      host.send(:setComputeDetails)
      assert_equal expected_message(nic.type), host.errors.full_messages.first
    end

    describe "validate compute provisioning" do
      setup do
        @image = images(:one)
        @host = FactoryBot.build_stubbed(:host, :operatingsystem => @image.operatingsystem, :image => @image,
                                  :compute_resource => @image.compute_resource)
      end

      test "it checks the image belongs to the compute resource" do
        @host.provision_method = 'image'
        @host.compute_attributes = { :image_id => @image.uuid }
        @host.stubs(:vm_exists?).returns(true)
        @host.stubs(:compute_update_required?).returns(false)
        assert @host.valid?

        @host.compute_attributes = { :image_id => 'not-existing-image' }
        refute @host.valid?
        assert @host.errors.full_messages.first =~ /image does not belong to/
      end

      test "removes the image from compute attributes if the provision method is build" do
        @host.provision_method = 'build'
        @host.compute_attributes = { :image_id => @image.uuid }
        assert @host.valid?
        assert_not_include @host.compute_attributes, :image_id
      end
    end
  end

  describe 'host on compute resource' do
    let(:host) do
      FactoryBot.build(:host,
        :managed,
        :on_compute_resource,
        :with_compute_profile)
    end

    test 'should queue compute orchestration' do
      host.compute_resource.stubs(:provided_attributes).returns({:mac => :mac})
      host.stubs(:vm_exists?).returns(false)
      assert_valid host
      tasks = host.queue.all.map(&:name)
      assert_includes tasks, "Set up compute instance #{host.provision_interface}"
      assert_includes tasks, "Query instance details for #{host.provision_interface}"
      assert_equal 2, tasks.size
    end
  end

  describe 'setting eui-64 ip address based on mac provided by compute resource' do
    let(:tax_organization) { FactoryBot.create(:organization) }
    let(:tax_location) { FactoryBot.create(:location) }
    let(:subnet6) do
      FactoryBot.build(:subnet_ipv6,
        :network => '2001:db8::',
        :mask => 'ffff:ffff:ffff:ffff::',
        :dns => FactoryBot.create(:dns_smart_proxy),
        :organizations => [tax_organization],
        :locations => [tax_location],
        :ipam => IPAM::MODES[:eui64])
    end

    let(:host) do
      FactoryBot.build(:host,
        :managed,
        :on_compute_resource,
        :with_compute_profile,
        :subnet6 => subnet6,
        :organization => tax_organization,
        :location => tax_location,
        :mac => nil)
    end

    test 'host gets an ip address from ipam' do
      host.vm = mock("vm")
      host.vm.stubs(:interfaces).returns([])
      host.vm.expects(:select_nic).once.returns(OpenStruct.new(:mac => 'aa:bb:cc:dd:ee:ff'))
      host.compute_resource.stubs(:provided_attributes).returns({:mac => :mac})
      host.stubs(:vm_exists?).returns(false)
      assert_valid host
      assert host.send(:setComputeDetails)
      assert host.send(:setComputeIPAM)
      assert_equal 'aa:bb:cc:dd:ee:ff', host.mac
      assert_equal '2001:db8::a8bb:ccff:fedd:eeff', host.ip6
    end

    test 'should queue ipam and dns orchestration' do
      host.compute_resource.stubs(:provided_attributes).returns({:mac => :mac})
      host.stubs(:vm_exists?).returns(false)
      assert_valid host
      tasks = host.queue.all.map(&:name)
      assert_includes tasks, "Set up compute instance #{host.provision_interface}"
      assert_includes tasks, "Query instance details for #{host.provision_interface}"
      assert_includes tasks, "Set IP addresses for #{host.provision_interface}"
      assert_includes tasks, "Create Reverse IPv6 DNS record for #{host.provision_interface}"
      assert_equal 4, tasks.size
    end

    test 'should fail the queue if ipam does not set required ip' do
      host.expects(:log_failure).with("Failed to set IPs via IPAM for #{host.name}: Ip6 can't be blank", nil).once
      ipam = mock('ipam')
      ipam.expects(:suggest_ip).returns(nil)
      subnet6.stubs(:unused_ip).returns(ipam)
      host.mac = 'aa:bb:cc:dd:ee:ff'
      refute host.send(:setComputeIPAM)
      assert_not_empty host.primary_interface.errors
      assert host.primary_interface.errors.added?(:ip6, :blank)
    end
  end
end
