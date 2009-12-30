require 'test_helper'

class OperatingsystemTest < ActiveSupport::TestCase
  test "shouldn't save with blank attributes" do
    operating_system = Operatingsystem.new
    assert !operating_system.save
  end

  test "name shouldn't contain white spaces" do
    operating_system = Operatingsystem.new :name => "  ", :major => 9
    assert !operating_system.save
  end

  test "major should be numeric" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "nine"
    assert !operating_system.save
  end

  test "minor should be numeric" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => 9, :minor => "one"
    assert !operating_system.save
  end

  test "to_label should print correctly" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => 9, :minor => 10
    assert operating_system.save
    operating_system = Operatingsystem.find_by_name "Ubuntu"
    assert operating_system.to_label == "Ubuntu 9.10"
  end

  test "to_version should print correctly" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => 9, :minor => 10
    assert operating_system.save
    operating_system = Operatingsystem.find_by_name "Ubuntu"
    assert operating_system.to_version == "9-10"
  end

  test "fullname should print correctly" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => 9, :minor => 10
    assert operating_system.save
    operating_system = Operatingsystem.find_by_name "Ubuntu"
    assert operating_system.fullname == "Ubuntu_9-10"
  end
end
