require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "should have login" do
    u = User.new :mail => "foo@bar.com"
    assert !u.save
  end
  
  test "should have mail" do
    u = User.new :login => "foo"
    assert !u.save  
  end
  
  test "login should be unique" do
    u = User.create :login => "foo", :mail => "foo@bar.com"
    u2 = User.new :login => u.login, :mail => u.mail
    
    assert !u2.valid?
  end
  
  test "mail should have format" do
    u = User.create :login => "foo", :mail => "bar"
    assert !u.valid?
  end
  
  # TODO; Authentication should be tested too.
end
