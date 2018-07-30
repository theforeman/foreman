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
        Fog::Compute::Ovirt::OperatingSystem.new({ :id => os[:id], :name => (os / 'name').text, :href => os[:href] })
      end
      @os_hashes = @ovirt_oses.map do |ovirt_os|
        { :id => ovirt_os.id, :name => ovirt_os.name, :href => ovirt_os.href }
      end
      @compute_resource = FactoryBot.build(:ovirt_cr)
      @host = FactoryBot.build(:host, :mac => 'ca:d0:e6:32:16:97')
    end

    it 'maps operating system to ovirt operating systems' do
      @compute_resource.stubs(:available_operating_systems).returns(@os_hashes)
      @compute_resource.determine_os_type(@host).must_equal "other_linux"

      @host.operatingsystem = operatingsystems(:redhat)
      @compute_resource.determine_os_type(@host).must_equal "rhel_6"

      @host.architecture = architectures(:x86_64)
      @compute_resource.determine_os_type(@host).must_equal "rhel_6x64"

      @host.operatingsystem = operatingsystems(:ubuntu1210)
      @compute_resource.determine_os_type(@host).must_equal "ubuntu_12_10"

      @host.operatingsystem = FactoryBot.create(:operatingsystem)
      @compute_resource.determine_os_type(@host).must_equal "other"
    end

    it 'respects host param ovirt_ostype' do
      @compute_resource.stubs(:available_operating_systems).returns(@os_hashes)
      @host.stubs(:params).returns({'ovirt_ostype' => 'some_os'})
      @compute_resource.determine_os_type(@host).must_equal "some_os"
    end

    it 'caches the operating systems in the compute resource' do
      client_mock = mock.tap { |m| m.stubs(:operating_systems).returns(@ovirt_oses) }
      @compute_resource.stubs(:client).returns(client_mock)
      assert @compute_resource.supports_operating_systems?
      assert_equal @os_hashes, @compute_resource.available_operating_systems
    end

    it 'handles a case when the operating systems endpoint is missing' do
      client_mock = mock.tap { |m| m.stubs(:operating_systems).raises(Fog::Ovirt::Errors::OvirtEngineError, StandardError.new('404')) }
      @compute_resource.stubs(:client).returns(client_mock)
      refute @compute_resource.supports_operating_systems?
    end
  end

  describe 'APIv4 support' do
    before do
      @compute_resource = FactoryBot.build(:ovirt_cr)
      @client_mock = mock.tap { |m| m.stubs(datacenters: [])}
    end

    it 'passes api_version properly' do
      Fog::Compute.expects(:new).with do |options|
        options[:api_version].must_equal 'v4'
      end.returns(@client_mock)
      @compute_resource.use_v4 = true
      @compute_resource.send(:client)
    end

    it 'passes api_version v3 by default' do
      Fog::Compute.expects(:new).with do |options|
        options[:api_version].must_equal 'v3'
      end.returns(@client_mock)
      @compute_resource.send(:client)
    end

    it 'accepts "1" and true as true values, anything else as false' do
      @compute_resource.use_v4 = true
      @compute_resource.use_v4?.must_equal true
      @compute_resource.use_v4 = false
      @compute_resource.use_v4?.must_equal false
      @compute_resource.use_v4 = '1'
      @compute_resource.use_v4?.must_equal true
      @compute_resource.use_v4 = '0'
      @compute_resource.use_v4?.must_equal false
    end
  end

  describe '#normalize_vm_attrs' do
    let(:cr) do
      mock_cr(FactoryBot.build(:ovirt_cr),
        :clusters => [
          stub(:id => 'c1', :name => 'cluster 1'),
          stub(:id => 'c2', :name => 'cluster 2')
        ],
        :templates => [
          stub(:id => 'tpl1', :name => 'template 1'),
          stub(:id => 'tpl2', :name => 'template 2')
        ],
        :networks => [
          stub(:id => 'net1', :name => 'network 1'),
          stub(:id => 'net2', :name => 'network 2')
        ],
        :storage_domains => [
          stub(:id => '312f6', :name => 'domain 1'),
          stub(:id => '382ec', :name => 'domain 2'),
          stub(:id => '3ea4f', :name => 'domain 3')
        ]
      )
    end

    test 'maps cluster to cluster_id' do
      assert_attrs_mapped(cr, 'cluster', 'cluster_id')
    end

    test 'finds cluster_name' do
      vm_attrs = {
        'cluster' => 'c2'
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal('cluster 2', normalized['cluster_name'])
    end

    test 'maps template to template_id' do
      assert_attrs_mapped(cr, 'template', 'template_id')
    end

    test 'finds template_name' do
      vm_attrs = {
        'template' => 'tpl2'
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal('template 2', normalized['template_name'])
    end

    test 'normalizes interfaces_attributes' do
      vm_attrs = {
        'interfaces_attributes' => {
          '0' => {
            'name' => 'eth0',
            'network' => 'net1'
          },
          '1' => {
            'name' => 'eth1',
            'network' => 'net2'
          }
        }
      }
      expected_attrs = {
        '0' => {
          'network_id' => 'net1',
          'network_name' => 'network 1',
          'name' => 'eth0'
        },
        '1' => {
          'network_id' => 'net2',
          'network_name' => 'network 2',
          'name' => 'eth1'
        }
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
            'preallocate' => '0'
          },
          '1' => {
            'size_gb' => '5',
            'storage_domain' => '382ec',
            'id' => '',
            'preallocate' => '1',
            'bootable' => 'true'
          }
        }
      }
      expected_attrs = {
        '0' => {
          'size' => 15.gigabyte.to_s,
          'storage_domain_id' => '312f6',
          'storage_domain_name' => 'domain 1',
          'preallocate' => false,
          'bootable' => nil
        },
        '1' => {
          'size' => 5.gigabyte.to_s,
          'storage_domain_id' => '382ec',
          'storage_domain_name' => 'domain 2',
          'preallocate' => true,
          'bootable' => true
        }
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
        'volumes_attributes' => {}
      }

      assert_equal(expected_attrs.keys.sort, normalized.keys.sort)
      assert_equal(expected_attrs, normalized)
    end

    test 'attribute names' do
      check_vm_attribute_names(cr)
    end
  end
end
