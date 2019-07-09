require 'test_helper'

class InterfaceMergeTest < ActiveSupport::TestCase
  def setup
    @merge = InterfaceMerge.new
    @attributes = compute_attributes(:with_interfaces)
    @profile_name = @attributes.compute_profile.name
  end

  EMPTY_ATTRS = {}

  def expected_attrs(num)
    {
      'attr' => num,
      'from_profile' => @profile_name,
    }
  end

  test "it doesn't change interfaces when the attributes are nil" do
    interfaces = [
      FactoryBot.build_stubbed(:nic_managed, :identifier => 'eth0'),
    ]
    @merge.run(stub(:interfaces => interfaces), nil)

    assert_equal 1, interfaces.length
    assert_equal EMPTY_ATTRS, interfaces[0].compute_attributes
    assert_equal 'eth0', interfaces[0].identifier
  end

  test "it merges compute attributes with existing NICs" do
    interfaces = [
      FactoryBot.build_stubbed(:nic_managed, :identifier => 'eth0'),
      FactoryBot.build_stubbed(:nic_managed, :identifier => 'eth1'),
      FactoryBot.build_stubbed(:nic_managed, :identifier => 'eth2'),
    ]
    @merge.run(stub(:interfaces => interfaces), @attributes)

    assert_equal 3, interfaces.length
    assert_equal expected_attrs(1), interfaces[0].compute_attributes
    assert_equal 'eth0', interfaces[0].identifier

    assert_equal expected_attrs(2), interfaces[1].compute_attributes
    assert_equal 'eth1', interfaces[1].identifier

    assert_equal EMPTY_ATTRS, interfaces[2].compute_attributes
    assert_equal 'eth2', interfaces[2].identifier
  end

  test "it overwrites NIC compute attributes from the profile by default" do
    interfaces = [
      FactoryBot.build_stubbed(:nic_managed, :identifier => 'eth0', :compute_attributes => {'attr' => 9}),
    ]
    @merge.run(stub(:interfaces => interfaces), @attributes)

    assert_equal expected_attrs(1), interfaces[0].compute_attributes
    assert_equal 'eth0', interfaces[0].identifier
  end

  test "it does not overwrite NIC compute attributes already set with :merge_compute_attributes" do
    @merge = InterfaceMerge.new(:merge_compute_attributes => true)
    interfaces = [
      FactoryBot.build_stubbed(:nic_managed, :identifier => 'eth0', :compute_attributes => {'attr' => 9}),
    ]
    @merge.run(stub(:interfaces => interfaces), @attributes)

    assert_equal expected_attrs(9), interfaces[0].compute_attributes
    assert_equal 'eth0', interfaces[0].identifier
  end

  test "it creates NICs when there aren't any" do
    interfaces = []
    @merge.run(stub(:interfaces => interfaces), @attributes)

    assert_equal 2, interfaces.length
    assert_equal expected_attrs(1), interfaces[0].compute_attributes
    assert_equal expected_attrs(2), interfaces[1].compute_attributes
  end

  test "it creates additional NICs" do
    interfaces = [
      FactoryBot.build_stubbed(:nic_managed, :identifier => 'eth0'),
    ]
    @merge.run(stub(:interfaces => interfaces), @attributes)

    assert_equal 2, interfaces.length
    assert_equal expected_attrs(1), interfaces[0].compute_attributes
    assert_equal 'eth0', interfaces[0].identifier

    assert_equal expected_attrs(2), interfaces[1].compute_attributes
    assert_nil interfaces[1].identifier
  end
end
