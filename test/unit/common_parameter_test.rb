require 'test_helper'

class CommonParameterTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end
  test "name can't be blank" do
    parameter = CommonParameter.new :name => "  ", :value => "some_value"
    assert parameter.name.strip.empty?
    assert !parameter.save
  end

  test "name can't contain white spaces" do
    parameter = CommonParameter.new :name => "   a new     param    ", :value => "some_value"
    assert !parameter.save

    parameter.name.gsub!(/\s+/,'_')
    assert parameter.save
  end

  test "value can't be blank" do
    parameter = CommonParameter.new :name => "some_parameter", :value => "   "
    assert parameter.value.strip.empty?
    assert !parameter.save
  end

  test "value can't be empty" do
    parameter = CommonParameter.new :name => "some_parameter", :value => ""
    assert parameter.value.strip.empty?
    assert !parameter.save
  end

  test "value can contain spaces and unusual characters" do
    parameter = CommonParameter.new :name => "some_parameter", :value => "   some crazy \"\'&<*%# value"
    assert parameter.save

    assert_equal parameter.value, "some crazy \"\'&<*%# value"
  end

  test "duplicate names cannot exist" do
    parameter1 = CommonParameter.create :name => "some_parameter", :value => "value"
    parameter2 = CommonParameter.create :name => "some_parameter", :value => "value"
    assert !parameter2.valid?
    assert  parameter2.errors.full_messages[0] == "Name has already been taken"
  end
end
