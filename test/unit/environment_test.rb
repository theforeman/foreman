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
  
  #TODO: Test the other methods of the class..
end
