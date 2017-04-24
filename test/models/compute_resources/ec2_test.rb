require 'test_helper'
require 'models/compute_resources/compute_resource_test_helpers'

class EC2Test < ActiveSupport::TestCase
  include ComputeResourceTestHelpers

  test "#associated_host matches any NIC" do
    host = FactoryGirl.create(:host, :ip => '10.0.0.154')
    cr = FactoryGirl.build(:ec2_cr)
    iface = mock('iface1', :public_ip_address => '10.0.0.154', :private_ip_address => "10.1.1.1")
    assert_equal host, as_admin { cr.associated_host(iface) }
  end

  describe "find_vm_by_uuid" do
    it "raises RecordNotFound when the vm does not exist" do
      cr = mock_cr_servers(Foreman::Model::EC2.new, empty_servers)
      assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
    end

    it "raises RecordNotFound when the compute raises EC2 error" do
      cr = mock_cr_servers(Foreman::Model::EC2.new, servers_raising_exception(Fog::Compute::AWS::Error))
      assert_find_by_uuid_raises(ActiveRecord::RecordNotFound, cr)
    end
  end

  context "key pairs" do
    setup do
      @aws_key_pairs = []
      3.times do |i|
        @aws_key_pairs << AWSKeyPair.new("foreman-#{i}", "13:01:73:0#{i}")
      end
    end

    test "#get_compute_key_pairs" do
      cr = FactoryGirl.build(:ec2_cr)
      key_pair = FactoryGirl.build(:key_pair)
      cr.key_pair = key_pair
      Foreman::Model::EC2.any_instance.stubs(:key_pairs).returns(@aws_key_pairs)
      assert_kind_of(ComputeResourceKeyPair, cr.get_compute_key_pairs.first)
    end

    test "should be capable of key_pair" do
      cr = FactoryGirl.create(:ec2_cr)
      assert_includes(cr.capabilities, :key_pair)
    end

    test "should not delete attached key pair" do
      compute_resource = FactoryGirl.create(:ec2_cr)
      key_pair = FactoryGirl.create(:key_pair, compute_resource: compute_resource)
      assert_raise Foreman::Exception do
        compute_resource.delete_key_pair(key_pair.name)
      end
      refute_nil(compute_resource.key_pair)
    end
  end
end

# We can't use 'Fog::Compute::AWS::KeyPair' model
# This class mocks it.
class AWSKeyPair
  attr_reader :name, :fingerprint, :private_key

  def initialize(name, fingerprint, private_key = nil)
    @name = name
    @fingerprint = fingerprint
    @private_key = private_key
  end
end
