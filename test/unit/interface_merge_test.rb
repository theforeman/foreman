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
      'from_profile' => @profile_name
    }
  end

  test "it doesn't change interfaces when the attributes are nil" do
    interfaces = [
      FactoryGirl.build(:nic_managed, :identifier => 'eth0')
    ]
    @merge.run(interfaces, nil)

    assert_equal 1, interfaces.length
    assert_equal EMPTY_ATTRS, interfaces[0].compute_attributes
    assert_equal 'eth0', interfaces[0].identifier
  end

  test "it merges compute attributes with existing NICs" do
    interfaces = [
      FactoryGirl.build(:nic_managed, :identifier => 'eth0'),
      FactoryGirl.build(:nic_managed, :identifier => 'eth1'),
      FactoryGirl.build(:nic_managed, :identifier => 'eth2')
    ]
    @merge.run(interfaces, @attributes)

    assert_equal 3, interfaces.length
    assert_equal expected_attrs(1), interfaces[0].compute_attributes
    assert_equal 'eth0', interfaces[0].identifier

    assert_equal expected_attrs(2), interfaces[1].compute_attributes
    assert_equal 'eth1', interfaces[1].identifier

    assert_equal EMPTY_ATTRS, interfaces[2].compute_attributes
    assert_equal 'eth2', interfaces[2].identifier
  end

  test "it creates NICs when there aren't any" do
    interfaces = []
    @merge.run(interfaces, @attributes)

    assert_equal 2, interfaces.length
    assert_equal expected_attrs(1), interfaces[0].compute_attributes
    assert_equal expected_attrs(2), interfaces[1].compute_attributes
  end

  test "it creates additional NICs" do
    interfaces = [
      FactoryGirl.build(:nic_managed, :identifier => 'eth0')
    ]
    @merge.run(interfaces, @attributes)

    assert_equal 2, interfaces.length
    assert_equal expected_attrs(1), interfaces[0].compute_attributes
    assert_equal 'eth0', interfaces[0].identifier

    assert_equal expected_attrs(2), interfaces[1].compute_attributes
    assert_equal nil, interfaces[1].identifier
  end
end
