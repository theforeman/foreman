require 'test_helper'

module Best
  module Provider
    class MyBest < ::ComputeResource; end
    class Libvirt < ::ComputeResource; end
  end
end

class ComputeResourceTest < ActiveSupport::TestCase
  def setup
    User.current = users(:admin)
  end

  test "password is saved encrypted when updated" do
    compute_resource = compute_resources(:one)
    compute_resource.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    compute_resource.password = "123456"
    as_admin do
      assert compute_resource.save
    end
    assert_equal compute_resource.password, "123456"
    refute_equal compute_resource.password_in_db, "123456"
  end

  test "password is saved encrypted when created" do
    Fog.mock!
    ComputeResource.any_instance.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    compute_resource = ComputeResource.new_provider(:name => "new12345", :provider => "EC2", :url => "eu-west-1",
                                                    :user => "username", :password => "abcdef")
    as_admin do
      assert compute_resource.save!
    end
    assert_equal compute_resource.password, "abcdef"
    refute_equal compute_resource.password_in_db, "abcdef"
    Fog.unmock!
  end

  test "random_password should return nil when set_console_password is false" do
    cr = compute_resources(:mycompute)
    cr.set_console_password = 0
    assert_nil cr.send(:random_password) # Can't call protected methods directly
  end

  test "random_password should return a string when set_console_password is true" do
    cr = compute_resources(:mycompute)
    cr.set_console_password = 1
    assert_match /^[[:alnum:]]+$/, cr.send(:random_password) # Can't call protected methods directly
  end

  test "attrs[:setpw] is set to nil if compute resource is not Libvirt or VMWare" do
    cr = compute_resources(:ec2)
    assert cr.update(:set_console_password => 1)
    assert_nil cr.attrs[:setpw]
  end

  test "attrs[:setpw] is set to 1 if compute resource is Libvirt" do
    cr = compute_resources(:mycompute)
    assert cr.update(:set_console_password => 1)
    assert_equal 1, cr.attrs[:setpw]
  end

  test "attrs[:setpw] is set to 0 rather than nil if compute resource is Libvirt" do
    cr = compute_resources(:mycompute)
    assert cr.update(:set_console_password => nil)
    assert_equal 0, cr.attrs[:setpw]
  end

  test "libvirt vm_instance_defaults should contain the stored display type" do
    cr = compute_resources(:mycompute)
    cr.display_type = 'VNC'
    assert_equal 'vnc', cr.send(:vm_instance_defaults)['display']['type']
    cr.display_type = 'SPICE'
    assert_equal 'spice', cr.send(:vm_instance_defaults)['display']['type']
  end

  test "libvirt: 'G' suffix should be appended to libvirt volume capacity if none was specified" do
    volume = OpenStruct.new(:capacity => 10, :allocation => '10')
    volume.stubs(:save!).returns(true)

    result = Foreman::Model::Libvirt.new.send(:create_volumes, {:prefix => 'test', :volumes => [volume]})

    assert_equal "10G", result[0].capacity
  end

  test "libvirt: no exceptions should be raised if a 'G' suffix was specified for volume capacity" do
    volume = OpenStruct.new(:capacity => "10G", :allocation => "10G")
    volume.stubs(:save!).returns(true)

    assert_nothing_raised { Foreman::Model::Libvirt.new.send(:create_volumes, {:prefix => 'test', :volumes => [volume]}) }
  end

  test "libvirt: an exception should be raised if a suffix other than 'G' was used in volume capacity value" do
    volume = OpenStruct.new(:capacity => "10K")

    assert_raise(Foreman::Exception) do
      Foreman::Model::Libvirt.new.send(:create_volumes, {:prefix => 'test', :volumes => [volume]})
    end
  end

  test "friendly provider name" do
    assert_equal "Libvirt", compute_resources(:one).provider_friendly_name
    assert_equal "EC2", compute_resources(:ec2).provider_friendly_name
    assert_equal "OpenStack", compute_resources(:openstack).provider_friendly_name
  end

  test "ensure compute resource with associated profile can get destroyed" do
    assert_difference('ComputeAttribute.count', -2) do
      compute_attributes(:one).compute_resource.destroy
    end
  end

  test '.supported_providers returns hash of names to classes' do
    supported = ComputeResource.supported_providers
    assert_kind_of Hash, supported
    supported.each do |name, klass|
      assert klass.constantize < ComputeResource, "Class #{klass} is not a ComputeResource"
    end
  end

  test '.registered_providers returns providers from plugins' do
    plugin1 = mock('plugin1', :compute_resources => ['Best::Provider::MyBest'])
    Foreman::Plugin.expects(:all).returns([plugin1])
    assert_equal({'MyBest' => 'Best::Provider::MyBest'}, ComputeResource.registered_providers)
  end

  test '.providers returns merge of loaded builtin and registered providers' do
    ComputeResource.expects(:registered_providers).returns({'Libvirt' => 'Best::Provider::Libvirt', 'MyBest' => 'Best::Provider::MyBest'})
    ComputeResource.expects(:supported_providers).returns({'Libvirt' => 'Foreman::Model::Libvirt', 'EC2' => 'Foreman::Model::EC2', 'GCE' => 'Foreman::Model::GCE'})
    Fog::Compute.expects(:providers).twice.returns([:aws, :libvirt])
    assert_equal(
      {
        'EC2' => 'Foreman::Model::EC2',
        'Libvirt' => 'Best::Provider::Libvirt',  # prefer plugin classes
        'MyBest' => 'Best::Provider::MyBest',
      },
      ComputeResource.providers
    )
  end

  test '.all_providers returns merge of builtin and registered providers' do
    ComputeResource.expects(:registered_providers).returns({'Libvirt' => 'Best::Provider::Libvirt', 'MyBest' => 'Best::Provider::MyBest'})
    ComputeResource.expects(:supported_providers).returns({'Libvirt' => 'Foreman::Model::Libvirt', 'EC2' => 'Foreman::Model::EC2'})
    assert_equal(
      {
        'EC2' => 'Foreman::Model::EC2',
        'Libvirt' => 'Best::Provider::Libvirt',  # prefer plugin classes
        'MyBest' => 'Best::Provider::MyBest',
      },
      ComputeResource.all_providers
    )
  end

  test '.provider_class returns provider class names' do
    ComputeResource.expects(:all_providers).at_least_once.returns({'Libvirt' => 'Best::Provider::Libvirt'})
    assert_equal 'Best::Provider::Libvirt', ComputeResource.provider_class('Libvirt')
  end

  test '.new_provider requires :provider argument' do
    e = assert_raise(Foreman::Exception) { ComputeResource.new_provider({}) }
    assert_match /must provide a provider/, e.message
  end

  test '.new_provider instantiates provider from arguments' do
    ComputeResource.expects(:providers).returns({'Libvirt' => 'Foreman::Model::Libvirt'})
    assert_instance_of Foreman::Model::Libvirt, ComputeResource.new_provider(:provider => 'Libvirt')
  end

  test '.new_provider raises error for unknown provider' do
    ComputeResource.expects(:providers).returns({'Libvirt' => 'Foreman::Model::Libvirt'})
    e = assert_raise(Foreman::Exception) { ComputeResource.new_provider({:provider => 'Unknown'}) }
    assert_match /unknown provider/, e.message
  end

  # test taxonomix methods
  test "should get used location ids for host" do
    FactoryBot.create(:host, :compute_resource => compute_resources(:one),
                       :location => taxonomies(:location1))
    assert_equal [taxonomies(:location1).id], compute_resources(:one).used_location_ids
  end

  test "should get used and selected location ids for host" do
    assert_equal [taxonomies(:location1).id], compute_resources(:one).used_or_selected_location_ids
  end

  test "user_data_supported?" do
    refute compute_resources(:one).user_data_supported?
    assert compute_resources(:ec2).user_data_supported?
  end

  test "invalid if provider is set to empty string" do
    cr = compute_resources(:mycompute)
    cr.provider = ''
    refute_valid cr, :provider, "can't be blank"
    refute_valid cr, :provider, "is not included in the list"
  end

  test "invalid if provider is set to non-existant provider" do
    cr = compute_resources(:mycompute)
    cr.provider = 'notrealprovider'
    refute_valid cr, :provider, "is not included in the list"
  end

  test "invalid if provider is changed on update" do
    cr = compute_resources(:ovirt)
    cr.provider = 'Libvirt'
    refute_valid cr, :provider, "cannot be changed"
  end

  test "description supports more than 255 characters" do
    description = "a" * 300
    assert (description.length > 255)
    cr = compute_resources(:mycompute)
    cr.description = description
    assert_valid cr
  end

  test "#associate_by returns host by MAC attribute" do
    host = FactoryBot.create(:host, :mac => '00:22:33:44:55:1a')
    cr = FactoryBot.build_stubbed(:compute_resource)
    assert_equal host, as_admin { cr.send(:associate_by, 'mac', '00:22:33:44:55:1a') }
  end

  test "#associate_by returns host by MAC attribute with upper case MAC" do
    host = FactoryBot.create(:host, :mac => '00:22:33:44:C8:1A')
    cr = FactoryBot.build_stubbed(:compute_resource)
    assert_equal host, as_admin { cr.send(:associate_by, 'mac', '00:22:33:44:c8:1a') }
  end

  test "#associated_by returns read/write host" do
    FactoryBot.create(:host, :mac => '00:22:33:44:55:1a')
    cr = FactoryBot.build_stubbed(:compute_resource)
    refute as_admin { cr.send(:associate_by, 'mac', '00:22:33:44:55:1a') }.readonly?
  end

  test "url has trailing slash removed on save" do
    cr = FactoryBot.build(:ec2_cr, url: 'http://example.com/')
    cr.save!
    assert_equal 'http://example.com', cr.url
  end

  describe "find_vm_by_uuid" do
    before do
      servers = mock()
      servers.stubs(:get).returns(nil)

      client = mock()
      client.stubs(:servers).returns(servers)

      @cr = ComputeResource.new
      @cr.stubs(:client).returns(client)
    end

    it "raises RecordNotFound when the vm does not exist" do
      assert_raises ActiveRecord::RecordNotFound do
        @cr.find_vm_by_uuid('abc')
      end
    end
  end

  describe "vm_compute_attributes_for" do
    before do
      @plain_attrs = {
        :id => 'abc',
        :cpus => 5,

      }
      @vm = mock()
      @vm.stubs(:attributes).returns(@plain_attrs)

      @cr = compute_resources(:ovirt)
      @cr.stubs(:find_vm_by_uuid).returns(@vm)
    end

    test "returns vm attributes without id" do
      require 'fog/ovirt/models/compute/volume'

      volume1 = Fog::Ovirt::Compute::Volume.new(:storage_domain => '', :size_gb => '1', :bootable => 'false',
                                             :sparse => 'true', :wipe_after_delete => 'true', :name => 'disk1')
      volume2 = Fog::Ovirt::Compute::Volume.new(:storage_domain => '', :size_gb => '1', :bootable => 'false',
                                             :sparse => 'true', :wipe_after_delete => 'true', :name => 'disk2')

      @vm.stubs(:volumes).returns([volume1, volume2])

      expected_attrs = {:cpus => 5, :volumes_attributes => {
        "0" => {:size_gb => 1, :storage_domain => "", :preallocate => "0", :wipe_after_delete => "true",
              :interface => nil, :bootable => "false", :id => nil},
          "1" => {:size_gb => 1, :storage_domain => "", :preallocate => "0", :wipe_after_delete => "true",
                :interface => nil, :bootable => "false", :id => nil}}
      }
      attrs = @cr.vm_compute_attributes_for('abc')

      assert_equal expected_attrs, attrs
    end

    test "returns correct vm attributes when vm volumes are nil" do
      @vm.stubs(:volumes).returns(nil)
      @vm.stubs(:attributes).returns(@plain_attrs.merge({:volumes_attributes => nil}))

      expected_attrs = {
        :cpus => 5,
        :volumes_attributes => {},
      }
      attrs = @cr.vm_compute_attributes_for('abc')

      assert_equal expected_attrs, attrs
    end

    test "returns default attributes when the vm no longer exists" do
      @cr.stubs(:find_vm_by_uuid).returns(nil)

      expected_attrs = {}
      attrs = @cr.vm_compute_attributes_for('abc')

      assert_equal expected_attrs, attrs
    end

    test "returns default attributes when the vm no longer exists and provider raises exception" do
      @cr.stubs(:find_vm_by_uuid).raises(ActiveRecord::RecordNotFound)

      expected_attrs = {}
      attrs = @cr.vm_compute_attributes_for('abc')

      assert_equal expected_attrs, attrs
    end

    test "compute resource name can have spaces" do
      cr = FactoryBot.build_stubbed(:compute_resource, :ec2, name: 'My Compute Resource')
      assert(cr.valid?, 'ComputeResource can have spaces in name')
    end
  end

  describe "host_interfaces_attrs" do
    before do
      @cr = compute_resources(:mycompute)
    end

    test "only physical interfaces are added to the compute attributes" do
      physical_nic = FactoryBot.build_stubbed(:nic_base, :virtual => false,
                                       :compute_attributes => { :id => '1', :virtual => false })
      virtual_nic = FactoryBot.build_stubbed(:nic_base, :virtual => true,
                                       :compute_attributes => { :id => '2', :virtual => true })
      host = FactoryBot.build_stubbed(:host, :interfaces => [physical_nic, virtual_nic])
      nic_attributes = @cr.host_interfaces_attrs(host).values.select(&:present?)
      assert_equal '1', nic_attributes.first[:id]
    end
  end

  context '#update_required?' do
    let(:compute_resource) { compute_resources(:mycompute) }

    test 'should not require an update if hashes are equal' do
      old_attrs = {:a => 'b', 'c' => {:a => '1', :d => 3}}
      new_attrs = {:a => 'b', :c => {'a' => 1}}
      assert_equal false, compute_resource.update_required?(old_attrs, new_attrs)
    end

    test 'should require an update if hashes are different' do
      old_attrs = {:a => 'b', 'c' => {:a => '1', :d => 3}}
      new_attrs = {:a => 'b', :c => {'a' => 2}}
      assert_equal true, compute_resource.update_required?(old_attrs, new_attrs)
    end
  end

  test 'capable? returns true if capabilities include the feature' do
    cr = compute_resources(:mycompute)
    cr.stubs(:capabilities).returns([:new_volume]) do
      assert cr.capable?(:new_volume)
    end
  end

  test 'capable? returns false if capabilities do not include the feature' do
    cr = compute_resources(:mycompute)
    cr.stubs(:capabilities).returns([:new_volume]) do
      refute cr.capable?(:build)
    end
  end

  describe '#nested_attribute_for' do
    test "handles ActionController::Parameters" do
      cr = compute_resources(:mycompute)
      hash = {:disk => "test"}
      volume_attributes = ActionController::Parameters.new("1520857914238" => ActionController::Parameters.new(hash))
      volumes = cr.send(:nested_attributes_for, :volumes, volume_attributes.permit("1520857914238" => {}))
      assert_equal hash, volumes[0]
    end

    test "handles Array" do
      cr = compute_resources(:mycompute)
      volume_attributes = [{:disk => "test"}, {size_gb: 10}]
      volumes = cr.send(:nested_attributes_for, :volumes, volume_attributes)
      assert_equal volume_attributes, volumes
    end
  end
end
