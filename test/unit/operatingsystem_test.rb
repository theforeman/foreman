require 'test_helper'

class OperatingsystemTest < ActiveSupport::TestCase
  test "shouldn't save with blank attributes" do
    operating_system = Operatingsystem.new
    assert !operating_system.save
  end

  test "name shouldn't be blank" do
    operating_system = Operatingsystem.new :name => "   ", :major => "9"
    assert operating_system.name.strip.empty?
    assert !operating_system.save
  end

  test "name shouldn't contain white spaces" do
    operating_system = Operatingsystem.new :name => " U bun     tu ", :major => "9"
    assert !operating_system.name.strip.squeeze(" ").tr(' ', '').empty?
    assert !operating_system.save

    operating_system.name.strip!.squeeze!(" ").tr!(' ', '')
    assert !operating_system.name.include?(' ')
    assert operating_system.save
  end

  test "major should be numeric" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9"
    assert operating_system.major.to_i != 0 if operating_system.major != "0"
    assert operating_system.save

    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "nine"
    assert !operating_system.major.to_i != 0 if operating_system.major != "0"
    assert !operating_system.save
  end

  test "minor should be numeric" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "1"
    assert operating_system.minor.to_i != 0 if operating_system.minor != "0"
    assert operating_system.save

    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "one"
    assert !operating_system.minor.to_i != 0 if operating_system.minor != "0"
    assert !operating_system.save
  end

  test "name and major should be unique" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "10"
    assert operating_system.save

    other_operating_system = Operatingsystem.new :name => "Ubuntu", :major => "10"
    assert !other_operating_system.save
  end

  test "should not destroy while using" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "10"
    assert operating_system.save

    host = Host.new :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => operating_system,
      :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition",
      :ptable => Ptable.first
    assert host.save!

    operating_system.hosts << host

    assert !operating_system.destroy
  end

  # Methods tests
  test "to_label should print correctly" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "10"
    assert operating_system.to_label == "Ubuntu 9.10"
  end

  test "to_version should print correctly" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "10"
    assert operating_system.to_version == "9-10"
  end

  test "fullname should print correctly" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "10"
    assert operating_system.fullname == "Ubuntu_9-10"
  end

  test "to_s retrives label" do
    operating_system = Operatingsystem.new :name => "Ubuntu", :major => "9", :minor => "10"
    assert operating_system.to_s == operating_system.to_label
  end
end
