require 'test_helper'
require 'models/compute_resources/compute_resource_test_helpers'

class Foreman::Model::VmwareTest < ActiveSupport::TestCase
  include ComputeResourceTestHelpers

  should validate_presence_of(:server)
  should validate_presence_of(:user)
  should validate_presence_of(:password)
  should validate_presence_of(:datacenter)
  should allow_values('vcenter.example.com', 'vcenter').for(:server)

  test 'error message is added for server attribute' do
    vmware_cr = FactoryBot.build_stubbed(:vmware_cr, :server => nil)
    vmware_cr.validate
    assert_includes vmware_cr.errors.full_messages, "Server can't be blank"
  end

  test "#create_vm calls new_vm when network provisioning" do
    interfaces_attributes = { "new_interfaces" => { "type" => "VirtualE1000",   "network" => "network-17", "_delete" => ""},
                              "0"              => { "type" => "VirtualVmxnet3", "network" => "network-17", "_delete" => ""}}
    volumes_attributes    = { "new_volumes" => { "size_gb" => "10", "_delete" => ""},
                              "0"           => { "size_gb" => "1",  "_delete" => ""}}

    attrs_in = HashWithIndifferentAccess.new("cpus"                  => "1",
                                             "interfaces_attributes" => interfaces_attributes,
                                             "volumes_attributes"    => volumes_attributes)

    attrs_parsed = HashWithIndifferentAccess.new("cpus"                  => "1",
                                                 "interfaces_attributes" => {"new_interfaces" => {"type" => "VirtualE1000", "network" => "Test network", "_delete" => ""},
                                                                            "0" => {"type" => "VirtualVmxnet3", "network" => "Test network", "_delete" => ""}},
                                                 "volumes_attributes"    => {"new_volumes" => {"size_gb" => "10", "_delete" => ""},
                                                                             "0" => {"size_gb" => "1", "_delete" => ""}})

    mock_vm = mock('vm')
    mock_vm.expects(:save).returns(mock_vm)
    mock_vm.expects(:firmware).returns('biod')

    cr = FactoryBot.build_stubbed(:vmware_cr)
    cr.expects(:parse_networks).with(attrs_in).returns(attrs_parsed)
    cr.expects(:new_vm).with(attrs_parsed).returns(mock_vm)
    cr.expects(:test_connection)
    assert_equal mock_vm, cr.create_vm(attrs_in)
  end

  test "#new_vm merges defaults with user args and creates server" do
    attrs_in = HashWithIndifferentAccess.new(
      "cpus"                  => "1",
      "interfaces_attributes" => {
        "new_interfaces" => {
          "type"    => "VirtualE1000",
          "network" => "network-17",
          "_delete" => "",
        },
        "0" => {
          "type"    => "VirtualVmxnet3",
          "network" => "network-17",
          "_delete" => "",
        },
      },
      "volumes_attributes" => {
        "new_volumes" => {
          "size_gb" => "10",
          "_delete" => "",
        },
        "0" => {
          "size_gb" => "1",
          "_delete" => "",
        },
      }
    )
    attrs_parsed = {
      :cpus       => "1",
      :interfaces => [
        {
          :type    => "VirtualVmxnet3",
          :network => "network-17",
          :_delete => "",
        },
      ],
      :volumes => [
        {
          :size_gb => "1",
          :_delete => "",
        },
      ],
    }
    attrs_out = {
      :name       => 'test',
      :cpus       => "1",
      :interfaces => [
        {
          :type    => "VirtualVmxnet3",
          :network => "network-17",
          :_delete => "",
        },
      ],
      :volumes => [
        {
          :size_gb => "1",
          :_delete => "",
        },
      ],
    }

    mock_vm = mock('new server')
    mock_servers = mock('client.servers')
    mock_servers.expects(:new).with(attrs_out).returns(mock_vm)
    mock_client = mock('client')
    mock_client.expects(:servers).returns(mock_servers)

    cr = FactoryBot.build_stubbed(:vmware_cr)
    cr.expects(:parse_args).with(attrs_in).returns(attrs_parsed)
    cr.expects(:vm_instance_defaults).returns(HashWithIndifferentAccess.new(:name => 'test', :cpus => '2', :interfaces => [mock('iface')], :volumes => [mock('vol')]))
    cr.expects(:client).returns(mock_client)
    assert_equal mock_vm, cr.new_vm(attrs_in)
  end

  describe "#create_vm" do
    setup do
      @cr = FactoryBot.build_stubbed(:vmware_cr)
      @cr.stubs(:test_connection)
    end
    test "calls clone_vm when image provisioning with symbol key and provision_method image" do
      args = {:image_id => "2", "provision_method" => "image" }
      @cr.stubs(:parse_networks).returns(args)
      @cr.expects(:clone_vm)
      @cr.expects(:new_vm).times(0)
      @cr.create_vm(args)
    end
    test "calls clone_vm when image provisioning with string key and provision_method image" do
      args = {"image_id" => "2", "provision_method" => "image" }
      @cr.stubs(:parse_networks).returns(args)
      @cr.expects(:clone_vm)
      @cr.expects(:new_vm).times(0)
      @cr.create_vm(args)
    end
    test "does not call clone_vm when image provisioning with string key and provision_method build" do
      args = {"image_id" => "2", "provision_method" => "build" }
      mock_vm = mock('vm')
      mock_vm.expects(:save).returns(mock_vm)
      mock_vm.stubs(:firmware).returns('bios')
      @cr.stubs(:parse_networks).returns(args)
      @cr.expects(:clone_vm).times(0)
      @cr.expects(:new_vm).returns(mock_vm)
      @cr.create_vm(args)
    end

    test 'converts automatic firmware to bios default' do
      args = {"provision_method" => "build"}
      mock_vm = mock('vm')
      mock_vm.expects(:save).returns(mock_vm)
      mock_vm.stubs(:firmware).returns('automatic')
      mock_vm.expects(:firmware=).with('bios')
      @cr.stubs(:parse_networks).returns(args)
      @cr.expects(:new_vm).returns(mock_vm)
      @cr.create_vm(args)
    end
  end

  test "#create_vm calls clone_vm when image provisioning" do
    attrs_in = HashWithIndifferentAccess.new(
      "image_id"              => "2",
      "cpus"                  => "1",
      "interfaces_attributes" => {
        "new_interfaces" => {
          "type"    => "VirtualE1000",
          "network" => "network-17",
          "_delete" => "",
        },
        "0" => {
          "type"    => "VirtualVmxnet3",
          "network" => "network-17",
          "_delete" => "",
        },
      },
      "volumes_attributes" => {
        "new_volumes" => {
          "size_gb" => "10",
          "_delete" => "",
        },
        "0" => {
          "size_gb" => "1",
          "_delete" => "",
        },
      }
    )
    attrs_parsed = HashWithIndifferentAccess.new(
      "image_id" => "2",
      "cpus" => "1",
      "interfaces_attributes" => {
        "new_interfaces" => {
          "type" => "VirtualE1000",
          "network" => "Test network",
          "_delete" => "",
        },
        "0" => {
          "type" => "VirtualVmxnet3",
          "network" => "Test network",
          "_delete" => "",
        },
      },
      "volumes_attributes" => {
        "new_volumes" => {
          "size_gb" => "10",
          "_delete" => "",
        },
        "0" => {"size_gb" => "1", "_delete" => ""},
      },
      "provision_method" => "image"
    )

    mock_vm = mock('vm')
    cr = FactoryBot.build_stubbed(:vmware_cr)
    cr.expects(:parse_networks).with(attrs_in).returns(attrs_parsed)
    cr.expects(:clone_vm).with(attrs_parsed).returns(mock_vm)
    cr.expects(:test_connection)
    assert_equal mock_vm, cr.create_vm(attrs_in)
  end

  describe "#parse_args" do
    setup do
      @cr = FactoryBot.build_stubbed(:vmware_cr)
    end

    test "converts empty hash" do
      assert_equal({}, @cr.parse_args(HashWithIndifferentAccess.new))
    end

    test "converts form attrs to fog attrs" do
      attrs_in = HashWithIndifferentAccess.new(
        "cpus"                  => "1",
        "interfaces_attributes" => {
          "new_interfaces" => {
            "type"    => "VirtualE1000",
            "network" => "network-17",
            "_delete" => "",
          },
          "0" => {
            "type"    => "VirtualVmxnet3",
            "network" => "network-17",
            "_delete" => "",
          },
        },
        "volumes_attributes" => {
          "new_volumes" => {
            "size_gb" => "10",
            "_delete" => "",
          },
          "0" => {
            "size_gb" => "1",
            "_delete" => "",
          },
        }
      )
      # All keys must be symbolized
      attrs_out = {:cpus => "1", :interfaces => [{:type => "VirtualVmxnet3", :network => "network-17", :_delete => ""}], :volumes => [{:size_gb => "1", :_delete => ""}]}
      assert_equal attrs_out, @cr.parse_args(attrs_in)
    end

    test "is ommiting hardware_version, when it's set to Default" do
      attrs_in = HashWithIndifferentAccess.new(
        "cpus"                  => "1",
        "hardware_version"      => "Default",
        "interfaces_attributes" => {
          "new_interfaces" => {
            "type"    => "VirtualE1000",
            "network" => "network-17",
            "_delete" => "",
          },
          "0" => {
            "type"    => "VirtualVmxnet3",
            "network" => "network-17",
            "_delete" => "",
          },
        },
        "volumes_attributes" => {
          "new_volumes" => {
            "size_gb" => "10",
            "_delete" => "",
          },
          "0" => {
            "size_gb" => "1",
            "_delete" => "",
          },
        }
      )
      attrs_out = {:cpus => "1", :interfaces => [{:type => "VirtualVmxnet3", :network => "network-17", :_delete => ""}], :volumes => [{:size_gb => "1", :_delete => ""}]}
      assert_equal attrs_out, @cr.parse_args(attrs_in)
    end

    test "is setting hardware_version, when it's set to a non-Default value" do
      attrs_in = HashWithIndifferentAccess.new(
        "cpus"                  => "1",
        "hardware_version"      => "vmx-08",
        "interfaces_attributes" => {
          "new_interfaces" => {
            "type"    => "VirtualE1000",
            "network" => "network-17",
            "_delete" => "",
          },
          "0" => {
            "type"    => "VirtualVmxnet3",
            "network" => "network-17",
            "_delete" => "",
          },
        },
        "volumes_attributes" => {
          "new_volumes" => {
            "size_gb" => "10",
            "_delete" => "",
          },
          "0" => {
            "size_gb" => "1",
            "_delete" => "",
          },
        }
      )
      attrs_out = {
        :cpus             => "1",
        :hardware_version => "vmx-08",
        :interfaces       => [
          {
            :type    => "VirtualVmxnet3",
            :network => "network-17",
            :_delete => "",
          },
        ],
        :volumes => [
          {
            :size_gb => "1",
            :_delete => "",
          },
        ],
      }
      assert_equal attrs_out, @cr.parse_args(attrs_in)
    end

    context 'firmware' do
      test 'chooses BIOS firmware when firmware type is None and firmware is automatic' do
        attrs_in = HashWithIndifferentAccess.new(:firmware_type => :none, 'firmware' => 'automatic')
        attrs_out = {:firmware => "bios"}
        assert_equal attrs_out, @cr.parse_args(attrs_in)
      end

      test 'chooses BIOS firmware when firmware type is bios and firmware is automatic' do
        attrs_in = HashWithIndifferentAccess.new(:firmware_type => :bios, 'firmware' => 'automatic')
        attrs_out = {:firmware => "bios"}
        assert_equal attrs_out, @cr.parse_args(attrs_in)
      end

      test 'chooses EFI firmware when pxe loader is set to UEFI and firmware is automatic' do
        attrs_in = HashWithIndifferentAccess.new(:firmware_type => :uefi, 'firmware' => 'automatic')
        attrs_out = {:firmware => "efi"}
        assert_equal attrs_out, @cr.parse_args(attrs_in)
      end

      test 'chooses BIOS firmware when no pxe loader is set and firmware is automatic' do
        attrs_in = HashWithIndifferentAccess.new('firmware' => 'automatic')
        attrs_out = {:firmware => "bios"}
        assert_equal attrs_out, @cr.parse_args(attrs_in)
      end
    end

    test "doesn't modify input hash" do
      # else compute profiles won't save properly
      attrs_in = HashWithIndifferentAccess.new("interfaces_attributes" => {"0" => {"network" => "network-17"}})
      @cr.parse_args(attrs_in)
      assert_equal "network-17", attrs_in["interfaces_attributes"]["0"]["network"]
    end

    context 'scsi_controller_type - from hammer' do
      test 'parse to be a default scsi_controller_type' do
        attrs_in = HashWithIndifferentAccess.new('scsi_controller_type' => 'ParaVirtualSCSIController')
        attrs_out = { scsi_controllers: [{ type: 'ParaVirtualSCSIController' }] }
        assert_equal attrs_out, @cr.parse_args(attrs_in)
      end

      test 'do not override scsi_controllers if passed' do
        attrs_in = HashWithIndifferentAccess.new(
          'scsi_controller_type' => 'ParaVirtualSCSIController',
          'scsi_controllers' => [{ 'type' => 'VirtualBusLogicController' }]
        )
        attrs_out = { scsi_controllers: [{ type: 'VirtualBusLogicController' }] }
        assert_equal attrs_out, @cr.parse_args(attrs_in)
      end

      test 'drop invalid scsi_controller_type attribute' do
        attrs_in = HashWithIndifferentAccess.new(
          'scsi_controller_type' => 'ParaVirtualSCSICntrlr'
        )
        attrs_out = {}
        assert_equal attrs_out, @cr.parse_args(attrs_in)
      end
    end
  end

  describe "#parse_networks" do
    def mock_network(id, name, virtualswitch = nil)
      mock_network = mock('network')
      mock_network.stubs('id').returns(id)
      mock_network.stubs('name').returns(name)
      mock_network.stubs('virtualswitch').returns(virtualswitch)
      mock_network
    end

    setup do
      @cr = FactoryBot.build_stubbed(:vmware_cr)
      @cr.stubs(:networks).returns(
        [
          mock_network('network-17', 'Test network'),
          mock_network('network-11', 'network-14'),
          mock_network('network-14', 'Network name'),
        ]
      )
    end

    test "converts empty hash" do
      assert_equal({}, @cr.parse_networks(HashWithIndifferentAccess.new))
    end

    test "converts form network name to network ID" do
      attrs_in = HashWithIndifferentAccess.new(
        "interfaces_attributes" => {
          "new_interfaces" => {
            "type"    => "VirtualE1000",
            "network" => "Test network",
            "_delete" => "",
          },
          "0" => {
            "type"    => "VirtualVmxnet3",
            "network" => "Test network",
            "_delete" => "",
          },
        }
      )
      attrs_out = HashWithIndifferentAccess.new(
        "interfaces_attributes" => {
          "new_interfaces" => {
            "type"          => "VirtualE1000",
            "network"       => "network-17",
            "virtualswitch" => nil,
            "_delete"       => "",
          },
          "0" => {
            "type"          => "VirtualVmxnet3",
            "network"       => "network-17",
            "virtualswitch" => nil,
            "_delete"       => "",
          },
        }
      )
      assert_equal attrs_out, @cr.parse_networks(attrs_in)
    end

    test "matches the network name, before id lookup" do
      attrs = HashWithIndifferentAccess.new(
        "interfaces_attributes" => {
          "0" => {
            "type"          => "VirtualVmxnet3",
            "network"       => "network-14",
            "virtualswitch" => nil,
            "_delete"       => "",
          },
        }
      )
      assert_equal 'network-11', @cr.parse_networks(attrs)['interfaces_attributes']['0']['network']
    end

    test "ignores existing network IDs" do
      attrs = HashWithIndifferentAccess.new(
        "interfaces_attributes" => {
          "new_interfaces" => {
            "type"          => "VirtualE1000",
            "network"       => "network-17",
            "virtualswitch" => nil,
            "_delete"       => "",
          },
          "0" => {
            "type"          => "VirtualVmxnet3",
            "network"       => "network-17",
            "virtualswitch" => nil,
            "_delete"       => "",
          },
        }
      )
      assert_equal attrs, @cr.parse_networks(attrs)
    end

    test "doesn't modify input hash" do
      # else compute profiles won't save properly
      attrs_in = HashWithIndifferentAccess.new("interfaces_attributes" => {"0" => {"network" => "Test network"}})
      @cr.parse_args(attrs_in)
      assert_equal "Test network", attrs_in["interfaces_attributes"]["0"]["network"]
    end
  end

  test "#associated_host matches primary NIC" do
    host = FactoryBot.create(:host, :mac => 'ca:d0:e6:32:16:97')
    cr = FactoryBot.build_stubbed(:vmware_cr)
    iface = mock('iface1', :mac => 'ca:d0:e6:32:16:97')
    vm = mock('vm', :interfaces => [iface])
    assert_equal host, as_admin { cr.associated_host(vm) }
  end

  test "#associated_host matches any NIC" do
    host = FactoryBot.create(:host, :mac => 'ca:d0:e6:32:16:98')
    Nic::Base.create! :mac => "ca:d0:e6:32:16:99", :host => host
    host.reload
    cr = FactoryBot.build_stubbed(:vmware_cr)
    iface1 = mock('iface1', :mac => 'ca:d0:e6:32:16:98')
    iface2 = mock('iface1', :mac => 'ca:d0:e6:32:16:99')
    vm = mock('vm', :interfaces => [iface1, iface2])
    assert_equal host, as_admin { cr.associated_host(vm) }
  end

  test "#associated_host matches NIC mac with uppercase letters" do
    host = FactoryBot.create(:host, :mac => 'ca:d0:e6:32:16:98')
    Nic::Base.create! :mac => "ca:d0:e6:32:16:99", :host => host
    host.reload
    cr = FactoryBot.build_stubbed(:vmware_cr)
    iface1 = mock('iface1', :mac => 'CA:D0:E6:32:16:98')
    iface2 = mock('iface1', :mac => 'ca:d0:e6:32:16:99')
    vm = mock('vm', :interfaces => [iface1, iface2])
    assert_equal host, as_admin { cr.associated_host(vm) }
  end

  describe "vm_compute_attributes_for" do
    before do
      plain_attrs = {
        :id => 'abc',
        :cpus => 5,
      }
      @vm = mock('vm')
      @vm.stubs(:attributes).returns(plain_attrs)
      @vm.stubs(:interfaces).returns([])

      @cr = compute_resources(:vmware)
      @cr.stubs(:find_vm_by_uuid).returns(@vm)

      vol1 = mock('vol1')
      vol1.stubs(:attributes).returns({:vol => 1})
      vol1.stubs(:size_gb).returns(4)
      vol2 = mock('vol2')
      vol2.stubs(:attributes).returns({:vol => 2})
      vol2.stubs(:size_gb).returns(4)
      @volumes = [
        vol1,
        vol2,
      ]
      @vm.stubs(:volumes).returns(@volumes)

      scsi_controller1 = mock('scsi_controller1')
      scsi_controller1.stubs(:attributes).returns({:type => "VirtualLsiLogicController", :shared_bus => "noSharing", :unit_number => 7, :key => 1000})
      @vm.stubs(:scsi_controllers).returns([scsi_controller1])

      @networks = [
        OpenStruct.new(:id => 'dvportgroup-123456', :name => 'Testnetwork'),
      ]
      @cr.stubs(:networks).returns(@networks)
    end

    test "returns vm attributes without id" do
      expected_attrs = {
        :cpus => 5,
        :volumes_attributes => {
          "0" => { :vol => 1, :size_gb => 4 },
          "1" => { :vol => 2, :size_gb => 4 },
        },
        :interfaces_attributes => {},
        :scsi_controllers => [
          {
            :type => "VirtualLsiLogicController",
            :shared_bus => "noSharing",
            :unit_number => 7,
            :key => 1000,
          },
        ],
      }
      attrs = @cr.vm_compute_attributes_for('abc')

      assert_equal expected_attrs, attrs
    end

    test "returns correct vm attributes when vm has interfaces" do
      interfaces = [
        OpenStruct.new(
          :mac => '00:50:56:84:f1:b1',
          :network => 'dvportgroup-123456',
          :name => 'Network adapter 1',
          :status => 'ok',
          :summary => 'DVSwitch: 8a 0e 04 61 f0 b9 99 42-78 a8 08 be c8 28 a0 1c',
          :type => 'RbVmomi::VIM::VirtualVmxnet3',
          :key => 4000,
          :virtualswitch => nil,
          :server_id => '5004913f-4ba3-7a6c-4481-b796d1234999'
        ),
      ]
      @vm.stubs(:interfaces).returns(interfaces)
      expected_attrs = {
        :cpus => 5,
        :volumes_attributes => {
          "0" => { :vol => 1, :size_gb => 4 },
          "1" => { :vol => 2, :size_gb => 4 },
        },
        :interfaces_attributes => {"0" => {:compute_attributes => {:network => "Testnetwork", :type => "VirtualVmxnet3"}, :mac => "00:50:56:84:f1:b1"}},
        :scsi_controllers => [
          {
            :type => "VirtualLsiLogicController",
            :shared_bus => "noSharing",
            :unit_number => 7,
            :key => 1000,
          },
        ],
      }
      attrs = @cr.vm_compute_attributes_for('abc')

      assert_equal expected_attrs, attrs
    end
  end

  describe '#display_type' do
    let(:cr) { FactoryBot.build_stubbed(:vmware_cr) }

    test "default display type is 'vmrc'" do
      assert_nil cr.attrs[:display]
      assert_equal 'vmrc', cr.display_type
    end

    test "display type can be set" do
      expected = 'vnc'
      cr.display_type = 'VNC'
      assert_equal expected, cr.attrs[:display]
      assert_equal expected, cr.display_type
      assert cr.valid?
    end

    test "don't allow wrong display type to be set" do
      cr.display_type = 'spice'
      refute cr.valid?
    end
  end

  describe '#clone_vm' do
    setup { Fog.mock! }
    teardown { Fog.unmock! }
    let(:cr) { FactoryBot.build_stubbed(:vmware_cr) }
    let(:default_args) do
      {
        name: 'test',
        cpus: '1',
        interfaces: [
          { type: 'VirtualVmxnet3', :network => 'network-17'},
        ],
        volumes: [
          { :size_gb => '1'},
        ],
      }
    end

    test 'raises an error when user_data is not valid yaml' do
      args = default_args.merge(
        user_data: "Totally invalid yaml.\t"
      )
      assert_raises Foreman::Exception do
        cr.clone_vm(args)
      end
    end

    test 'raises an error when parsed user_data is not a valid hash' do
      args = default_args.merge(
        user_data: '--- true'
      )
      assert_raises Foreman::Exception do
        cr.clone_vm(args)
      end
    end

    test 'ignores customspec when user_data is nil' do
      args = default_args.merge(
        user_data: '---'
      )
      cr.send(:client).expects(:cloudinit_to_customspec).never
      cr.send(:client).stubs(:vm_clone).returns({'new_vm' => {'id' => 123}})
      cr.clone_vm(args)
    end

    test 'passes customspec when user_data is a valid yaml hash' do
      args = default_args.merge(
        user_data: "---\n{}"
      )
      Fog::Vsphere::Compute::Real.any_instance.expects(:cloudinit_to_customspec).never
      cr.send(:client).stubs(:vm_clone).returns({'new_vm' => {'id' => 123}})
      cr.clone_vm(args)
    end
  end

  describe '#normalize_vm_attrs' do
    let(:base_cr) { FactoryBot.build(:vmware_cr) }
    let(:cr) do
      mock_cr(base_cr,
        :folders => [
          stub(:path => 'some/path', :name => 'some path'),
          stub(:path => 'another/path', :name => 'another path'),
        ],
        :available_clusters => [
          stub(:id => 'c1', :name => 'cluster 1'),
          stub(:id => 'c2', :name => 'cluster 2'),
        ],
        :resource_pools => [],
        :datastores => [
          stub(:id => 'ds1', :name => 'store 1'),
          stub(:id => 'ds2', :name => 'store 2'),
        ],
        :networks => [
          stub(:id => 'net1', :name => 'network 1'),
          stub(:id => 'net2', :name => 'network 2'),
        ],
        :subnets => [
          stub(:subnet_id => 'sn1', :cidr_block => 'cidr blk 1'),
          stub(:subnet_id => 'sn2', :cidr_block => 'cidr blk 2'),
        ]
      )
    end

    test 'corespersocket mapped to cores_per_socket' do
      assert_attrs_mapped(cr, 'corespersocket', 'cores_per_socket')
    end

    test 'memory_mb mapped to memory' do
      vm_attrs = {
        'memory_mb' => '768',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(768 * 1024, normalized['memory'])
    end

    test 'path mapped to folder_path' do
      assert_attrs_mapped(cr, 'path', 'folder_path')
    end

    test 'finds folder_name' do
      vm_attrs = {
        'path' => 'some/path',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal('some path', normalized['folder_name'])
    end

    test 'cluster mapped to cluster_name' do
      assert_attrs_mapped(cr, 'cluster', 'cluster_name')
    end

    test 'sets cluster_name to nil when cluster is blank' do
      assert_blank_mapped_attr_nilified(cr, 'cluster', 'cluster_name')
    end

    test 'finds cluster_id' do
      vm_attrs = {
        'cluster' => 'cluster 2',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal('c2', normalized['cluster_id'])
    end

    test 'finds resource_pool_id' do
      vm_attrs = {
        'cluster' => 'cluster 2',
        'resource_pool' => 'pool 2',
      }
      cr.expects(:resource_pools).with(:cluster_id => 'cluster 2').returns(
        [
          stub(:id => 'rp1', :name => 'pool 1'),
          stub(:id => 'rp2', :name => 'pool 2'),
        ]
      )
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal('rp2', normalized['resource_pool_id'])
    end

    test 'resource_pool mapped to resource_pool_name' do
      assert_attrs_mapped(cr, 'resource_pool', 'resource_pool_name')
    end

    test 'sets resource_pool_name to nil when resource_pool is blank' do
      assert_blank_mapped_attr_nilified(cr, 'resource_pool', 'resource_pool_name')
    end

    test 'finds guest_name' do
      vm_attrs = {
        'guest_id' => 'asianux3_64Guest',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal('Asianux Server 3 (64-bit)', normalized['guest_name'])
    end

    test 'hardware_version mapped to hardware_version_id' do
      assert_attrs_mapped(cr, 'hardware_version', 'hardware_version_id')
    end

    test 'finds hardware_version_name' do
      vm_attrs = {
        'hardware_version' => 'vmx-13',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal('13 (ESXi 6.5)', normalized['hardware_version_name'])
    end

    test "sets memory_hot_add_enabled to true when memoryHotAddEnabled is '1'" do
      vm_attrs = {
        'memoryHotAddEnabled' => '1',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(true, normalized['memory_hot_add_enabled'])
    end

    test "sets memory_hot_add_enabled to false when memoryHotAddEnabled is '0'" do
      vm_attrs = {
        'memoryHotAddEnabled' => '0',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(false, normalized['memory_hot_add_enabled'])
    end

    test "sets cpu_hot_add_enabled to true when cpuHotAddEnabled is '1'" do
      vm_attrs = {
        'cpuHotAddEnabled' => '1',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(true, normalized['cpu_hot_add_enabled'])
    end

    test "sets cpu_hot_add_enabled to false when cpuHotAddEnabled is '0'" do
      vm_attrs = {
        'cpuHotAddEnabled' => '0',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(false, normalized['cpu_hot_add_enabled'])
    end

    test "sets add_cdrom to true when it's '1'" do
      vm_attrs = {
        'add_cdrom' => '1',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(true, normalized['add_cdrom'])
    end

    test "sets add_cdrom to false when it's '0'" do
      vm_attrs = {
        'add_cdrom' => '0',
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(false, normalized['add_cdrom'])
    end

    describe 'images' do
      let(:base_cr) { FactoryBot.create(:vmware_cr, :with_images) }

      test 'adds image name' do
        vm_attrs = {
          'image_id' => cr.images.last.uuid,
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert_equal(cr.images.last.name, normalized['image_name'])
      end

      test 'leaves image name empty when image_id is nil' do
        vm_attrs = {
          'image_id' => nil,
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert(normalized.has_key?('image_name'))
        assert_nil(normalized['image_name'])
      end

      test "leaves image name empty when image wasn't found" do
        vm_attrs = {
          'image_id' => 'unknown',
        }
        normalized = cr.normalize_vm_attrs(vm_attrs)

        assert(normalized.has_key?('image_name'))
        assert_nil(normalized['image_name'])
      end
    end

    test 'normalizes scsi_controllers' do
      vm_attrs = {
        'scsi_controllers' => [
          {
            'type' => 'VirtualLsiLogicController',
            'key' => 1000,
          }, {
            'type' => 'VirtualLsiLogicController',
            'key' => 1001,
          }
        ],
      }
      expected_attrs = {
        '0' => {
          'type' => 'VirtualLsiLogicController',
          'key' => 1000,
        },
        '1' => {
          'type' => 'VirtualLsiLogicController',
          'key' => 1001,
        },
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(expected_attrs, normalized['scsi_controllers'])
    end

    test 'normalizes volumes_attributes' do
      vm_attrs = {
        'volumes_attributes' => {
          '0' => {
            'thin' => '0',
            'eager_zero' => true,
            'name' => 'Hard disk',
            'mode' => 'persistent',
            'controller_key' => 1000,
            'size_gb' => 10,
            'datastore' => 'store 1',
          },
        },
      }
      expected_attrs = {
        '0' => {
          'thin' => false,
          'eager_zero' => true,
          'name' => 'Hard disk',
          'mode' => 'persistent',
          'controller_key' => 1000,
          'size' => 10.gigabyte.to_s,
          'datastore_name' => 'store 1',
          'datastore_id' => 'ds1',
        },
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(expected_attrs, normalized['volumes_attributes'])
    end

    test 'normalizes interfaces_attributes' do
      vm_attrs = {
        'interfaces_attributes' => {
          '0' => {
            'type' => 'VirtualE1000',
            'network' => 'net1',
          },
        },
      }
      expected_attrs = {
        '0' => {
          'type_id' => 'VirtualE1000',
          'type_name' => 'E1000',
          'network_id' => 'net1',
          'network_name' => 'network 1',
        },
      }
      normalized = cr.normalize_vm_attrs(vm_attrs)

      assert_equal(expected_attrs, normalized['interfaces_attributes'])
    end

    test 'correctly fills empty attributes' do
      normalized = cr.normalize_vm_attrs({})
      expected_attrs = {
        'cpus' => nil,
        'firmware' => nil,
        'guest_id' => nil,
        'guest_name' => nil,
        'annotation' => nil,
        'cores_per_socket' => nil,
        'memory' => nil,
        'folder_path' => nil,
        'folder_name' => nil,
        'cluster_id' => nil,
        'cluster_name' => nil,
        'resource_pool_id' => nil,
        'resource_pool_name' => nil,
        'hardware_version_id' => nil,
        'hardware_version_name' => nil,
        'image_id' => nil,
        'image_name' => nil,
        'add_cdrom' => nil,
        'memory_hot_add_enabled' => nil,
        'cpu_hot_add_enabled' => nil,
        'scsi_controllers' => {},
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
end
