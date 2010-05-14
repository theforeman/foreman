require 'test_helper'

class ParameterTest < ActiveSupport::TestCase
  test "name can't be blank" do
    parameter = Parameter.new :name => "  ", :value => "some_value"
    assert parameter.name.strip.empty?
    assert !parameter.save
  end

  test "name can't contain trailing spaces" do
    parameter = Parameter.new :name => "   a new     param    ", :value => "some_value"
    assert !parameter.name.strip.squeeze(" ").empty?
    assert !parameter.save

    parameter.name.strip!.squeeze!(" ")
    assert parameter.save
  end

  test "value can't be blank" do
    parameter = Parameter.new :name => "some parameter", :value => "   "
    assert parameter.value.strip.empty?
    assert !parameter.save
  end

  test "value can't contain trailing spaces" do
    parameter = Parameter.new :name => "some parameter", :value => "   some crazy      value    "
    assert !parameter.value.strip.squeeze(" ").empty?
    assert !parameter.save

    parameter.value.strip!.squeeze!(" ").empty?
    assert parameter.save
  end

  test  "name must not be unique accross different parameter groups" do
    p1 = HostParameter.new :name => "param", :value => "value1", :host_id => Host.first
    assert p1.save
    p2 = DomainParameter.new :name => "param", :value => "value2", :domain_id => Domain.first
    assert p2.save
    p3 = CommonParameter.new :name => "param", :value => "value3"
    assert p3.save
    p4 = GroupParameter.new :name => "param", :value => "value4", :hostgroup_id => Hostgroup.first
    assert p4.save
  end
end
