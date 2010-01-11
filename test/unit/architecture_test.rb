require 'test_helper'

class ArchitectureTest < ActiveSupport::TestCase
  test "should not save without a name" do
    architecture = Architecture.new
    assert !architecture.save
  end

  test "name should not be blank" do
    architecture = Architecture.new :name => "   "
    assert architecture.name.strip.empty?
    assert !architecture.save
  end

  test "name should not contain white spaces" do
    architecture = Architecture.new :name => " i38  6 "
    assert !architecture.name.strip.squeeze(" ").tr(' ', '').empty?
    assert !architecture.save

    architecture.name.strip!.squeeze!(" ").tr!(' ', '')
    assert architecture.save
  end

  test "name should be unique" do
    architecture = Architecture.new :name => "i386"
    assert architecture.save

    other_architecture = Architecture.new :name => "i386"
    assert !other_architecture.save
  end

  test "to_s retrives name" do
    architecture = Architecture.new :name => "i386"
    assert architecture.to_s == architecture.name
  end

  test "should not destroy while using" do
    architecture = Architecture.new :name => "i386"
    assert architecture.save

    host = Host.new :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
      :domain => Domain.find_or_create_by_name("company.com"), :operatingsystem => Operatingsystem.first,
      :architecture => architecture, :environment => Environment.first, :disk => "empty partition",
      :ptable => Ptable.first
    assert host.save!

    architecture.hosts << host

    assert !architecture.destroy
  end
end
