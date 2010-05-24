require 'test_helper'

class HostParameterTest < ActiveSupport::TestCase
  test "should have a reference_id" do
    host_parameter = HostParameter.new
    host_parameter.name = "valid"
    host_parameter.value = "valid"
    assert !host_parameter.save

    host = Host.first
    host_parameter.reference_id = host.id
    assert host_parameter.save
  end

  test "duplicate names cannot exist for a host" do
    host = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
    :domain => domains(:mydomain) , :operatingsystem => Operatingsystem.first, :hostgroup => hostgroups(:common),
    :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    parameter1 = HostParameter.create :name => "some parameter", :value => "value", :reference_id => host.id
    parameter2 = HostParameter.create :name => "some parameter", :value => "value", :reference_id => host.id
    assert !parameter2.valid?
    assert  parameter2.errors.full_messages[0] == "Name has already been taken"
  end

  test "duplicate names can exist for different hosts" do
    host1 = Host.create :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
    :domain => domains(:mydomain) , :operatingsystem => Operatingsystem.first, :hostgroup => hostgroups(:common),
    :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"
    host2 = Host.create :name => "anotherfullhost", :mac => "aabbecddee00", :ip => "123.05.02.04",
    :domain => domains(:mydomain) , :operatingsystem => Operatingsystem.first, :hostgroup => hostgroups(:common),
    :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

    parameter1 = HostParameter.create :name => "some parameter", :value => "value", :reference_id => host1.id
    parameter2 = HostParameter.create :name => "some parameter", :value => "value", :reference_id => host2.id
    assert parameter2.valid?
  end

end

