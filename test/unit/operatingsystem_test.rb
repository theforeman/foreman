require 'test_helper'

class OperatingsystemTest < ActiveSupport::TestCase
  test "shouldn't save with blank attributes" do
    o = Operatingsystem.new
    assert !o.save
  end

  test "name shouldn't contain white spaces" do
    o = Operatingsystem.new :name => "  ", :major => 9
    assert !o.save
  end

  test "major should be numeric" do
    o = Operatingsystem.new :name => "Ubuntu", :major => "nine"
    assert !o.save
  end

  test "minor should be numeric" do
    o = Operatingsystem.new :name => "Ubuntu", :major => 9, :minor => "one"
    assert !o.save
  end

  test "to_label should print correctly" do
    o = Operatingsystem.new :name => "Ubuntu", :major => 9, :minor => 10
    assert o.save
    o = Operatingsystem.find_by_name "Ubuntu"
    assert o.to_label == "Ubuntu 9.10"
  end

  test "to_version should print correctly" do
    o = Operatingsystem.new :name => "Ubuntu", :major => 9, :minor => 10
    assert o.save
    o = Operatingsystem.find_by_name "Ubuntu"
    assert o.to_version == "9-10"
  end

  test "fullname should print correctly" do
    o = Operatingsystem.new :name => "Ubuntu", :major => 9, :minor => 10
    assert o.save
    o = Operatingsystem.find_by_name "Ubuntu"
    assert o.fullname == "Ubuntu_9-10"
  end
end
