require 'test_helper'

class InterfaceTypeMapperTest < ActiveSupport::TestCase
  def setup
    @mapper = InterfaceTypeMapper
  end

  test "it maps name to interface class name" do
    assert_equal Nic::Managed.name, @mapper.map("interface")
    assert_equal Nic::BMC.name, @mapper.map("bmc")
    assert_equal Nic::Bond.name, @mapper.map("bond")
  end

  test "it accepts class names for legacy reasons" do
    assert_equal Nic::Managed.name, @mapper.map("Nic::Managed")
    assert_equal Nic::BMC.name, @mapper.map("Nic::BMC")
    assert_equal Nic::Bond.name, @mapper.map("Nic::Bond")
  end

  test "it returns Managed as default for nil input" do
    assert_equal Nic::Managed.name, @mapper.map(nil)
  end

  test "it raises exception on unknown name" do
    assert_raises InterfaceTypeMapper::UnknownTypeException do
      @mapper.map("unknown")
    end
  end
end
