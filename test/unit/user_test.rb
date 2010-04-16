require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.create :login => "foo", :mail => "foo@bar.com"
  end
  
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

    assert !u.valid?
  end

  test "login should also be unique across usergroups" do
    ug = Usergroup.create :name => "foo"
    u  = User.create :login => "foo", :mail => "foo@bar.com"

    assert !u.valid?
  end

  test "mail should have format" do
    u = User.create :login => "foo", :mail => "bar"
    assert !u.valid?
  end

  test "login size should not exceed the 30 characters" do
    u = User.new :login => "a" * 31, :mail => "foo@bar.com"
    assert !u.save
  end

  test "firstname should have the correct format" do
    @user.firstname = "The Riddle?"
    assert !@user.save

    @user.firstname = " _''. - nah"
    assert @user.save!
  end

  test "lastname should have the correct format" do
    @user.lastname = "it's the JOKER$$$"
    assert !@user.save

   @user.lastname = " _''. - nah"
    assert @user.save!
  end

  test "firstname should not exceed the 30 characters" do
    @user.firstname = "a" * 31
    assert !@user.save
  end

 test "lastname should not exceed the 30 characters" do
    @user.firstname = "a" * 31
    assert !@user.save
  end

  test "mail should not exceed the 60 characters" do
    u = User.create :login => "foo", :mail => "foo" * 20 + "@bar.com"
    assert !u.save
  end

  test "to_label method should return a firstname and the lastname" do
    @user.firstname = "Ali Al"
    @user.lastname = "Salame"
    assert @user.save!

    assert_equal "Ali Al Salame", @user.to_label
  end

  test "when try to login if password is empty should return nil" do
    assert_equal nil, User.try_to_login("anything", "")
  end
  # couldn't continue testing the rest of login method cause use auth_source.authenticate, which is not implemented yet
end

