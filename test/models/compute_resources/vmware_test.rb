require 'test_helper'

class VmwareTest < ActiveSupport::TestCase
  test "#create_vm calls new_vm when network provisioning" do
    interfaces_attributes = { "new_interfaces" => { "type" => "VirtualE1000",   "network" => "network-17", "_delete" => ""},
                              "0"              => { "type" => "VirtualVmxnet3", "network" => "network-17", "_delete" => ""}}
    volumes_attributes    = { "new_volumes" => { "size_gb" => "10", "_delete" => ""},
                              "0"           => { "size_gb" => "1",  "_delete" => ""}}

    attrs_in = HashWithIndifferentAccess.new("cpus"                  => "1",
                                             "interfaces_attributes" => interfaces_attributes,
                                             "volumes_attributes"    => volumes_attributes)

    attrs_parsed = HashWithIndifferentAccess.new("cpus"                  => "1",
                                                 "interfaces_attributes" => {"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"Test network", "_delete"=>""},
                                                                            "0" => {"type"=>"VirtualVmxnet3", "network"=>"Test network", "_delete"=>""}},
                                                 "volumes_attributes"    => {"new_volumes"=>{"size_gb"=>"10", "_delete"=>""},
                                                                             "0"=>{"size_gb"=>"1", "_delete"=>""}})

    mock_vm = mock('vm')
    mock_vm.expects(:save).returns(mock_vm)
    mock_vm.expects(:firmware).returns('biod')

    cr = FactoryGirl.build(:vmware_cr)
    cr.expects(:parse_networks).with(attrs_in).returns(attrs_parsed)
    cr.expects(:new_vm).with(attrs_parsed).returns(mock_vm)
    cr.expects(:test_connection)
    assert_equal mock_vm, cr.create_vm(attrs_in)
  end

  test "#new_vm merges defaults with user args and creates server" do
    attrs_in = HashWithIndifferentAccess.new("cpus"=>"1", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
    attrs_parsed = {:cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"network-17", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}
    attrs_out = {:name => 'test', :cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"network-17", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}

    mock_vm = mock('new server')
    mock_servers = mock('client.servers')
    mock_servers.expects(:new).with(attrs_out).returns(mock_vm)
    mock_client = mock('client')
    mock_client.expects(:servers).returns(mock_servers)

    cr = FactoryGirl.build(:vmware_cr)
    cr.expects(:parse_args).with(attrs_in).returns(attrs_parsed)
    cr.expects(:vm_instance_defaults).returns(HashWithIndifferentAccess.new(:name => 'test', :cpus => '2', :interfaces => [mock('iface')], :volumes => [mock('vol')]))
    cr.expects(:client).returns(mock_client)
    assert_equal mock_vm, cr.new_vm(attrs_in)
  end

  describe "#create_vm" do
    setup do
      @cr = FactoryGirl.build(:vmware_cr)
      @cr.stubs(:test_connection)
    end
    test "calls clone_vm when image provisioning with symbol key and provision_method image" do
      args = {:image_id =>"2", "provision_method" => "image" }
      @cr.stubs(:parse_networks).returns(args)
      @cr.expects(:clone_vm)
      @cr.expects(:new_vm).times(0)
      @cr.create_vm(args)
    end
    test "calls clone_vm when image provisioning with string key and provision_method image" do
      args = {"image_id" =>"2", "provision_method" => "image" }
      @cr.stubs(:parse_networks).returns(args)
      @cr.expects(:clone_vm)
      @cr.expects(:new_vm).times(0)
      @cr.create_vm(args)
    end
    test "does not call clone_vm when image provisioning with string key and provision_method build" do
      args = {"image_id" =>"2", "provision_method" => "build" }
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
    attrs_in = HashWithIndifferentAccess.new("image_id"=>"2","cpus"=>"1", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
    attrs_parsed = HashWithIndifferentAccess.new(
      "image_id" => "2",
      "cpus" => "1",
      "interfaces_attributes" => {
        "new_interfaces" => {
          "type" => "VirtualE1000",
          "network" => "Test network",
          "_delete" => ""
        },
        "0"=>{
          "type" => "VirtualVmxnet3",
          "network" => "Test network",
          "_delete" => ""
        }
      },
      "volumes_attributes"=>{
        "new_volumes"=>{
          "size_gb" => "10",
          "_delete" => ""
        },
        "0" => {"size_gb"=>"1", "_delete"=>""}
      },
      "provision_method" => "image"
    )

    mock_vm = mock('vm')
    cr = FactoryGirl.build(:vmware_cr)
    cr.expects(:parse_networks).with(attrs_in).returns(attrs_parsed)
    cr.expects(:clone_vm).with(attrs_parsed).returns(mock_vm)
    cr.expects(:test_connection)
    assert_equal mock_vm, cr.create_vm(attrs_in)
  end

  describe "#parse_args" do
    setup do
      @cr = FactoryGirl.build(:vmware_cr)
    end

    test "converts empty hash" do
      assert_equal({}, @cr.parse_args(HashWithIndifferentAccess.new))
    end

    test "converts form attrs to fog attrs" do
      attrs_in = HashWithIndifferentAccess.new("cpus"=>"1", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
      # All keys must be symbolized
      attrs_out = {:cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"network-17", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}
      assert_equal attrs_out, @cr.parse_args(attrs_in)
    end

    test "is ommiting hardware_version, when it's set to Default" do
      attrs_in = HashWithIndifferentAccess.new("cpus"=>"1", "hardware_version"=>"Default", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
      attrs_out = {:cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"network-17", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}
      assert_equal attrs_out, @cr.parse_args(attrs_in)
    end

    test "is setting hardware_version, when it's set to a non-Default value" do
      attrs_in = HashWithIndifferentAccess.new("cpus"=>"1", "hardware_version"=>"vmx-08", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
      attrs_out = {:cpus=>"1", :hardware_version=>"vmx-08", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"network-17", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}
      assert_equal attrs_out, @cr.parse_args(attrs_in)
    end

    test "converts scsi_controller_type to hash" do
      attrs_in = HashWithIndifferentAccess.new("cpus"=>"1", "scsi_controller_type"=>"ParaVirtualSCSIController", "interfaces_attributes"=>{}, "volumes_attributes"=>{})
      attrs_out = {:cpus=>"1", :interfaces=>[], :volumes=>[], :scsi_controller=>{:type=>"ParaVirtualSCSIController"}}
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
      attrs_in = HashWithIndifferentAccess.new("interfaces_attributes"=>{"0"=>{"network"=>"network-17"}})
      @cr.parse_args(attrs_in)
      assert_equal "network-17", attrs_in["interfaces_attributes"]["0"]["network"]
    end
  end

  describe "#parse_networks" do
    setup do
      @mock_network = mock('network')
      @mock_network.stubs('id').returns('network-17')
      @mock_network.stubs('name').returns('Test network')
      @mock_network.stubs('virtualswitch').returns(nil)
      @cr = FactoryGirl.build(:vmware_cr)
      @cr.stubs(:networks).returns([@mock_network])
    end

    test "converts empty hash" do
      assert_equal({}, @cr.parse_networks(HashWithIndifferentAccess.new))
    end

    test "converts form network ID to network name" do
      attrs_in = HashWithIndifferentAccess.new("interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}})
      attrs_out = HashWithIndifferentAccess.new("interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"Test network", "virtualswitch" => nil, "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"Test network", "virtualswitch" => nil, "_delete"=>""}})
      assert_equal attrs_out, @cr.parse_networks(attrs_in)
    end

    test "ignores existing network names" do
      attrs = HashWithIndifferentAccess.new("interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"Test network", "virtualswitch" => nil, "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"Test network", "virtualswitch" => nil, "_delete"=>""}})
      assert_equal attrs, @cr.parse_networks(attrs)
    end

    test "doesn't modify input hash" do
      # else compute profiles won't save properly
      attrs_in = HashWithIndifferentAccess.new("interfaces_attributes"=>{"0"=>{"network"=>"network-17"}})
      @cr.parse_args(attrs_in)
      assert_equal "network-17", attrs_in["interfaces_attributes"]["0"]["network"]
    end
  end

  test "#associated_host matches primary NIC" do
    host = FactoryGirl.create(:host, :mac => 'ca:d0:e6:32:16:97')
    cr = FactoryGirl.build(:vmware_cr)
    iface = mock('iface1', :mac => 'ca:d0:e6:32:16:97')
    vm = mock('vm', :interfaces => [iface])
    assert_equal host, as_admin { cr.associated_host(vm) }
  end

  test "#associated_host matches any NIC" do
    host = FactoryGirl.create(:host, :mac => 'ca:d0:e6:32:16:98')
    Nic::Base.create! :mac => "ca:d0:e6:32:16:99", :host => host
    host.reload
    cr = FactoryGirl.build(:vmware_cr)
    iface1 = mock('iface1', :mac => 'ca:d0:e6:32:16:98')
    iface2 = mock('iface1', :mac => 'ca:d0:e6:32:16:99')
    vm = mock('vm', :interfaces => [iface1, iface2])
    assert_equal host, as_admin { cr.associated_host(vm) }
  end

  describe "vm_compute_attributes_for" do
    before do
      plain_attrs = {
        :id => 'abc',
        :cpus => 5
      }
      @vm = mock('vm')
      @vm.stubs(:attributes).returns(plain_attrs)

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
        vol2
      ]
    end

    test "returns vm attributes without id" do
      @vm.stubs(:volumes).returns(@volumes)

      expected_attrs = {
        :cpus => 5,
        :volumes_attributes => {
          "0" => { :vol => 1, :size_gb => 4 },
          "1" => { :vol => 2, :size_gb => 4 }
        }
      }
      attrs = @cr.vm_compute_attributes_for('abc')

      assert_equal expected_attrs, attrs
    end
  end
end
