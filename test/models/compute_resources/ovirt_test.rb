require 'test_helper'
require 'models/compute_resources/compute_resource_test_helpers'

class Foreman::Model:: OvirtTest < ActiveSupport::TestCase
  include ComputeResourceTestHelpers

  should validate_presence_of(:url)
  should validate_presence_of(:user)
  should validate_presence_of(:password)
  should allow_values('http://foo.com', 'http://bar.com/baz').for(:url)
  should_not allow_values('ftp://foo.com', 'buz').for(:url)

  test "#associated_host matches any NIC" do
    host = FactoryBot.create(:host, :mac => 'ca:d0:e6:32:16:97')
    cr = FactoryBot.build_stubbed(:ovirt_cr)
    iface1 = mock('iface1', :mac => '36:48:c5:c9:86:f2')
    iface2 = mock('iface2', :mac => 'ca:d0:e6:32:16:97')
    vm = mock('vm', :interfaces => [iface1, iface2])
    assert_equal host, as_admin { cr.associated_host(vm) }
  end

  test "#associated_host matches NIC mac with uppercase letters" do
    host = FactoryBot.create(:host, :mac => 'ca:d0:e6:32:16:97')
    cr = FactoryBot.build_stubbed(:ovirt_cr)
    iface1 = mock('iface1', :mac => '36:48:c5:c9:86:f2')
    iface2 = mock('iface2', :mac => 'CA:D0:E6:32:16:97')
    vm = mock('vm', :interfaces => [iface1, iface2])
    assert_equal host, as_admin { cr.associated_host(vm) }
  end

  describe "destroy_vm" do
    it "handles situation when vm is not present" do
      cr = mock_cr_servers(Foreman::Model::Ovirt.new, empty_servers)
      cr.expects(:find_vm_by_uuid).raises(ActiveRecord::RecordNotFound)
      assert cr.destroy_vm('abc')
    end
  end

  describe "find_vm_by_uuid" do
    it "raises RecordNotFound when the vm does not exist" do
      cr = mock_cr_servers(Foreman::Model::Ovirt.new, empty_servers)
      assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
    end

    it "raises RecordNotFound when the compute raises retrieve error" do
      exception = Fog::Ovirt::Errors::OvirtEngineError.new(StandardError.new('VM not found'))
      cr = mock_cr_servers(Foreman::Model::Ovirt.new, servers_raising_exception(exception))
      assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
    end
  end

  describe "associating operating system" do
    require 'fog/ovirt/models/compute/operating_system'

    setup do
      operating_systems_xml = Nokogiri::XML(File.read('test/fixtures/ovirt_operating_systems.xml'))
      @ovirt_oses = operating_systems_xml.xpath('/operating_systems/operating_system').map do |os|
        Fog::Ovirt::Compute::OperatingSystem.new({ :id => os[:id], :name => (os / 'name').text, :href => os[:href] })
      end
      @os_hashes = @ovirt_oses.map do |ovirt_os|
        { :id => ovirt_os.id, :name => ovirt_os.name, :href => ovirt_os.href }
      end
      @compute_resource = FactoryBot.build(:ovirt_cr)
      @host = FactoryBot.build(:host, :mac => 'ca:d0:e6:32:16:97')
      @quota = Fog::Ovirt::Compute::Quota.new({ :id => '1', :name => "Default" })
    end

    it 'maps operating system to ovirt operating systems' do
      @compute_resource.stubs(:available_operating_systems).returns(@os_hashes)
      _(@compute_resource.determine_os_type(@host)).must_equal "other_linux"

      @host.operatingsystem = operatingsystems(:redhat)
      _(@compute_resource.determine_os_type(@host)).must_equal "rhel_6"

      @host.architecture = architectures(:x86_64)
      _(@compute_resource.determine_os_type(@host)).must_equal "rhel_6x64"

      @host.operatingsystem = operatingsystems(:ubuntu1210)
      _(@compute_resource.determine_os_type(@host)).must_equal "ubuntu_12_10"

      @host.operatingsystem = FactoryBot.create(:operatingsystem)
      _(@compute_resource.determine_os_type(@host)).must_equal "other"
    end

    it 'respects host param ovirt_ostype' do
      @compute_resource.stubs(:available_operating_systems).returns(@os_hashes)
      @host.stubs(:params).returns({'ovirt_ostype' => 'some_os'})
      _(@compute_resource.determine_os_type(@host)).must_equal "some_os"
    end

    it 'caches the operating systems in the compute resource' do
      client_mock = mock.tap { |m| m.stubs(:operating_systems).returns(@ovirt_oses) }
      @compute_resource.stubs(:client).returns(client_mock)
      client_mock.stubs(:quotas).returns([@quota])
      assert @compute_resource.supports_operating_systems?
      assert_equal @os_hashes, @compute_resource.available_operating_systems
    end

    it 'handles a case when the operating systems endpoint is missing' do
      client_mock = mock.tap { |m| m.stubs(:operating_systems).raises(Fog::Ovirt::Errors::OvirtEngineError, StandardError.new('404')) }
      @compute_resource.stubs(:client).returns(client_mock)
      client_mock.stubs(:quotas).returns([@quota])
      refute @compute_resource.supports_operating_systems?
    end
  end

  describe 'APIv4 support' do
    require 'fog/ovirt/models/compute/quota'

    before do
      @compute_resource = FactoryBot.build(:ovirt_cr)
      @quota = Fog::Ovirt::Compute::Quota.new({ :id => '1', :name => "Default" })
      @client_mock = mock.tap { |m| m.stubs(datacenters: [], quotas: [@quota]) }
    end

    it 'passes api_version v4 by default' do
      Fog::Compute.expects(:new).with do |options|
        _(options[:api_version]).must_equal 'v4'
      end.returns(@client_mock)
      @compute_resource.send(:client)
    end
  end

  describe 'quota validation and name-id substitution' do
    require 'fog/ovirt/models/compute/quota'

    before do
      @compute_resource = FactoryBot.build(:ovirt_cr)
      @quota = Fog::Ovirt::Compute::Quota.new({ :id => '1', :name => 'Default' })
      @client_mock = mock.tap { |m| m.stubs(datacenters: [], quotas: [@quota]) }
      @compute_resource.stubs(:client).returns(@client_mock)
    end

    test 'quota validation - id entered' do
      @compute_resource.ovirt_quota = '1'
      assert_equal('1', @compute_resource.validate_quota)
    end

    test 'quota validation - name entered' do
      @compute_resource.ovirt_quota = 'Default'
      assert_equal('1', @compute_resource.validate_quota)
    end

    test 'quota validation - nothing entered' do
      assert_equal('1', @compute_resource.validate_quota)
    end

    test 'quota validation - name entered' do
      @compute_resource.ovirt_quota = 'Default2'
      assert_raise Foreman::Exception do
        @compute_resource.validate_quota
      end
    end
  end

  describe 'name-id substitution for attributes: network, storage_domain and cluster' do
    let(:cr) do
      mock_cr(FactoryBot.build(:ovirt_cr),
        :clusters => [
          stub(:id => 'c1', :name => 'cluster 1'),
          stub(:id => 'c2', :name => 'cluster 2'),
        ],
        :networks => [
          stub(:id => 'net1', :name => 'network 1'),
          stub(:id => 'net2', :name => 'network 2'),
        ],
        :storage_domains => [
          stub(:id => '312f6', :name => 'domain 1'),
          stub(:id => '382ec', :name => 'domain 2'),
        ]
      )
    end

    test 'cluster validation - id entered' do
      assert_equal('c2', cr.get_ovirt_id(cr.clusters, 'cluster', 'c2'))
    end

    test 'cluster validation - name entered' do
      assert_equal('c2', cr.get_ovirt_id(cr.clusters, 'cluster', 'cluster 2'))
    end

    test 'cluster validation - not valid' do
      assert_raise Foreman::Exception do
        cr.get_ovirt_id(cr.clusters, 'cluster', 'c3')
      end
    end

    test 'storage domain validation - id entered' do
      assert_equal('312f6', cr.get_ovirt_id(cr.storage_domains, 'storage domain', '312f6'))
    end

    test 'storage domain validation - name entered' do
      assert_equal('382ec', cr.get_ovirt_id(cr.storage_domains, 'storage domain', 'domain 2'))
    end

    test 'storage domain validation - not valid' do
      assert_raise Foreman::Exception do
        cr.get_ovirt_id(cr.storage_domains, 'storage domain', 'domain 3')
      end
    end

    test 'network validation - id entered' do
      assert_equal('net1', cr.get_ovirt_id(cr.networks, 'network', 'net1'))
    end

    test 'network validation - name entered' do
      assert_equal('net2', cr.get_ovirt_id(cr.networks, 'network', 'network 2'))
    end

    test 'network validation - not valid' do
      assert_raise Foreman::Exception do
        cr.get_ovirt_id(cr.networks, 'network', 'network 3')
      end
    end
  end

  describe '#normalize_vm_attrs' do
    let(:cr) do
      mock_cr(FactoryBot.build(:ovirt_cr),
        :clusters => [
          stub(:id => 'c1', :name => 'cluster 1'),
          stub(:id => 'c2', :name => 'cluster 2'),
        ],
        :templates => [
          stub(:id => 'tpl1', :name => 'template 1'),
          stub(:id => 'tpl2', :name => 'template 2'),
        ],
        :networks => [
          stub(:id => 'net1', :name => 'network 1'),
          stub(:id => 'net2', :name => 'network 2'),
        ],
        :storage_domains => [
          stub(:id => '312f6', :name => 'domain 1'),
          stub(:id => '382ec', :name => 'domain 2'),
          stub(:id => '3ea4f', :name => 'domain 3'),
        ]
      )
    end

    test 'maps cluster to cluster_id' do
      vm_attrs = {
        'cluster' => 'cluster 1',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      refute(normalized.has_key?('cluster'))
      assert_equal('c1', normalized['cluster_id'])
    end

    test 'finds cluster_name' do
      vm_attrs = {
        'cluster' => 'c2',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal('cluster 2', normalized['cluster_name'])
    end

    test 'maps template to template_id' do
      vm_attrs = {
        'template' => 'template 1',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      refute(normalized.has_key?('template'))
      assert_equal('tpl1', normalized['template_id'])
    end

    test 'finds template_name' do
      vm_attrs = {
        'template' => 'tpl2',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal('template 2', normalized['template_name'])
    end

    test 'normalizes interfaces_attributes' do
      vm_attrs = {
        'interfaces_attributes' => {
          '0' => {
            'name' => 'eth0',
            'network' => 'net1',
          },
          '1' => {
            'name' => 'eth1',
            'network' => 'net2',
          },
        },
      }
      expected_attrs = {
        '0' => {
          'network_id' => 'net1',
          'network_name' => 'network 1',
          'name' => 'eth0',
        },
        '1' => {
          'network_id' => 'net2',
          'network_name' => 'network 2',
          'name' => 'eth1',
        },
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(expected_attrs, normalized['interfaces_attributes'])
    end

    test 'normalizes volumes_attributes' do
      vm_attrs = {
        'volumes_attributes' => {
          '0' => {
            'size_gb' => '15',
            'storage_domain' => '312f6',
            'id' => '',
            'preallocate' => '0',
          },
          '1' => {
            'size_gb' => '5',
            'storage_domain' => '382ec',
            'id' => '',
            'preallocate' => '1',
            'bootable' => 'true',
          },
        },
      }
      expected_attrs = {
        '0' => {
          'size' => 15.gigabyte.to_s,
          'storage_domain_id' => '312f6',
          'storage_domain_name' => 'domain 1',
          'preallocate' => false,
          'bootable' => nil,
        },
        '1' => {
          'size' => 5.gigabyte.to_s,
          'storage_domain_id' => '382ec',
          'storage_domain_name' => 'domain 2',
          'preallocate' => true,
          'bootable' => true,
        },
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(expected_attrs, normalized['volumes_attributes'])
    end

    test 'correctly fills empty attributes' do
      normalized = cr.normalize_vm_attrs({})
      expected_attrs = {
        'cores' => nil,
        'memory' => nil,
        'cluster_id' => nil,
        'cluster_name' => nil,
        'template_id' => nil,
        'template_name' => nil,
        'interfaces_attributes' => {},
        'volumes_attributes' => {},
      }

      assert_equal(expected_attrs.keys.sort, normalized.keys.sort)
      assert_equal(expected_attrs, normalized)
    end

    test 'attribute names' do
      check_vm_attribute_names(cr)
    end
  end

  describe '#display_type' do
    let(:cr) { FactoryBot.build_stubbed(:ovirt_cr) }

    test "default display type is 'vnc'" do
      assert_nil cr.attrs[:display]
      assert_equal 'vnc', cr.display_type
    end

    test "display type can be set" do
      expected = 'spice'
      cr.display_type = 'Spice'
      assert_equal expected, cr.attrs[:display]
      assert_equal expected, cr.display_type
      assert cr.valid?
    end

    test "don't allow wrong display type to be set" do
      cr.display_type = 'teletype'
      refute cr.valid?
    end
  end

  describe '#keyboard_layout' do
    let(:cr) { FactoryBot.build_stubbed(:ovirt_cr) }

    test "default keyboard layout is 'en-us'" do
      assert_nil cr.attrs[:keyboard_layout]
      assert_equal 'en-us', cr.keyboard_layout
    end

    test "keyboard layout can be set" do
      expected = 'hu'
      cr.keyboard_layout = 'hu'
      assert_equal expected, cr.attrs[:keyboard_layout]
      assert_equal expected, cr.keyboard_layout
      assert cr.valid?
    end

    test "don't allow wrong keyboard layout to be set" do
      cr.keyboard_layout = 'fake-layout'
      refute cr.valid?
    end
  end
end
