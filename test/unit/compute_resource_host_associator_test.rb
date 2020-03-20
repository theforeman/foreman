require 'test_helper'

class ComputeResourceHostAssociatorTest < ActiveSupport::TestCase
  let(:associator) do
    ComputeResourceHostAssociator.new(compute_resource)
  end
  let(:compute_resource) { FactoryBot.create(:ec2_cr) }
  let(:vm1) { stub('vm1', :identity => Foreman.uuid) }
  let(:vm2) { stub('vm2', :identity => Foreman.uuid) }
  let(:vm3) { stub('vm3', :identity => Foreman.uuid) }
  let(:vms) { [vm1, vm2, vm3] }
  let(:host_with_vm) do
    FactoryBot.create(:host, :compute_resource => compute_resource).tap do |host|
      host.stubs(:vm_exists?).returns(true)
    end
  end
  let(:host_without_vm) { FactoryBot.build(:host) }

  test 'associates vm with a host if they match' do
    host_with_vm.update!(:uuid => vm2.identity)
    compute_resource.expects(:vms).returns(vms)
    compute_resource.stubs(:associated_host).returns(nil)
    compute_resource.expects(:associated_host).with(vm1).returns(host_without_vm)

    associator.associate_hosts

    _(host_without_vm.uuid).must_equal(vm1.identity)
    _(associator.hosts).must_equal([host_without_vm])
    _(associator.fail_count).must_equal 0
  end

  test 'rescues from errors occurred during the associated_host call ===' do
    host_with_vm.update!(:uuid => vm2.identity)
    compute_resource.expects(:vms).returns(vms)
    compute_resource.stubs(:associated_host).raises('Error associating a host')
    compute_resource.expects(:associated_host).with(vm1).returns(host_without_vm)

    associator.associate_hosts

    _(associator.fail_count).must_equal 1
  end
end
