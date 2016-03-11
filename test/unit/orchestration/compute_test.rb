require 'test_helper'

class ComputeOrchestrationTest < ActiveSupport::TestCase
  describe 'compute details' do
    setup do
      @cr = FactoryGirl.build(:libvirt_cr)
      @host = FactoryGirl.build(:host, :compute_resource => @cr)
      @host.vm = mock("vm")
    end

    test "are set for CR providing MAC" do
      @host.expects(:match_macs_to_nics).returns(true)
      @cr.stubs(:provided_attributes).returns({:mac => :mac})
      assert(@host.send :setComputeDetails)
    end

    test "are set for CR providing IP" do
      an_ip = '1.2.3.4'
      @cr.stubs(:provided_attributes).returns({:ip => :ip})
      @host.vm.expects(:ip).returns(an_ip)
      @host.expects(:ip=).returns(an_ip)
      @host.expects(:validate_foreman_attr).returns(true)
      assert(@host.send :setComputeDetails)
    end

    test "are set for CR providing an unknown attribute" do
      a_value = 'value'
      @cr.stubs(:provided_attributes).returns({:attr => :attr})
      @host.vm.expects(:attr).returns(a_value)
      @host.expects(:attr=).returns(a_value)
      @host.expects(:validate_foreman_attr).returns(true)
      assert(@host.send :setComputeDetails)
    end
  end

  test "a helpful error message shows up if no user_data is provided and it's necessary" do
    image = images(:one)
    host = FactoryGirl.build(:host, :operatingsystem => image.operatingsystem, :image => image,
                                    :compute_resource => image.compute_resource)
    host.send(:setUserData)
    assert host.errors.full_messages.first =~ /associate it/
  end

  test "rolling back userdata after it is set, deletes the attribute" do
    image = images(:one)
    host = FactoryGirl.build(:host, :operatingsystem => image.operatingsystem, :image => image,
                             :compute_resource => image.compute_resource)
    prov_temp = FactoryGirl.create(:provisioning_template, :template_kind => TemplateKind.create(:name =>"user_data"))
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
      @cr = FactoryGirl.build(:libvirt_cr)
      @cr.stubs(:provided_attributes).returns({:mac => :mac})
      @physical = FactoryGirl.build(:nic_base, :virtual => false)
      @virtual = FactoryGirl.build(:nic_base, :virtual => true)

      @host = FactoryGirl.build(:host,
                                :compute_resource => @cr)
      @host.interfaces = [ @virtual, @physical ]
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
      cr = FactoryGirl.build(:vmware_cr)
      cr.stubs(:provided_attributes).returns({:mac => :mac})

      host = FactoryGirl.build(:host, :interfaces => [nic], :compute_resource => cr)
      host.vm = mock("vm")
      host.vm.stubs(:interfaces).returns([])
      host.vm.stubs(:select_nic).returns(nil)
      host
    end

    def expected_message(identifier)
      "Could not find virtual machine network interface matching #{identifier}"
    end

    test "it adds message with NIC identifier" do
      nic = FactoryGirl.build(:nic_primary_and_provision, :name => 'test')
      host = host_for_nic_orchestration(nic)
      host.send(:setComputeDetails)
      assert_equal expected_message(nic.identifier), host.errors.full_messages.first
    end

    test "it adds message with NIC ip" do
      nic = FactoryGirl.build(:nic_primary_and_provision, :name => 'test', :identifier => '')
      host = host_for_nic_orchestration(nic)
      host.send(:setComputeDetails)
      assert_equal expected_message(nic.ip), host.errors.full_messages.first
    end

    test "it adds message with NIC name" do
      nic = FactoryGirl.build(:nic_primary_and_provision, :name => 'test', :identifier => nil, :ip => '')
      host = host_for_nic_orchestration(nic)
      host.send(:setComputeDetails)
      assert_equal expected_message(nic.name), host.errors.full_messages.first
    end

    test "it adds message with NIC type" do
      nic = FactoryGirl.build(:nic_primary_and_provision, :name => '', :identifier => nil, :ip => nil)
      host = host_for_nic_orchestration(nic)
      host.send(:setComputeDetails)
      assert_equal expected_message(nic.type), host.errors.full_messages.first
    end

    describe "validate compute provisioning" do
      setup do
        @image = images(:one)
        @host = FactoryGirl.build(:host, :operatingsystem => @image.operatingsystem, :image => @image,
                                  :compute_resource => @image.compute_resource)
      end

      test "it checks the image belongs to the compute resource" do
        @host.provision_method = 'image'
        @host.compute_attributes = { :image_id => @image.uuid }
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
end
