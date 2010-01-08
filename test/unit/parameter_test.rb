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
end
