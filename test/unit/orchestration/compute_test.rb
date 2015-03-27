require 'test_helper'

class ComputeOrchestrationTest < ActiveSupport::TestCase
  test "a helpful error message shows up if no user_data is provided and it's necessary" do
    image = images(:one)
    host = FactoryGirl.build(:host, :operatingsystem => image.operatingsystem, :image => image,
                                    :compute_resource => image.compute_resource)
    host.send(:setUserData)
    assert host.errors.full_messages.first =~ /associate it/
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
  end
end
