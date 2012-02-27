require 'test_helper'

class EnvironmentTest < ActiveSupport::TestCase
  test "should have name" do
    env = Environment.new
    assert !env.valid?
  end

  test "name should be unique" do
    env = Environment.create :name => "foo"
    env2 = Environment.new :name => env.name
    assert !env2.valid?
  end

  test "name should have no spaces" do
    env = Environment.new :name => "f o o"
    assert !env.valid?
  end

  test "name should be alphanumeric" do
    env = Environment.new :name => "test&fail"
    assert !env.valid?
  end

  test "to_label should print name" do
    env = Environment.new :name => "foo"
    assert_equal env.to_label, env.name
  end

  test "to_s should print name" do
    env = Environment.new :name => "foo"
    assert_equal env.to_s, env.name
  end

end
