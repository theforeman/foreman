require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    User.current = User.find_by_login "admin"
    @user = User.create :auth_source => auth_sources(:one), :login => "foo", :mail  => "foo@bar.com"
  end

  test "should have login" do
    u = User.new :auth_source => auth_sources(:one), :mail => "foo@bar.com"
    assert !u.save
  end

  test "should have mail" do
    u = User.new :auth_source => auth_sources(:one), :login => "foo"
    assert !u.save
  end

  test "login should be unique" do
    u = User.new :auth_source => auth_sources(:one), :login => "foo", :mail  => "foo@bar.com"

    assert !u.valid?
  end

  test "login should also be unique across usergroups" do
    ug = Usergroup.create :name => "foo"
    u  = User.new :auth_source => auth_sources(:one), :login => "foo", :mail  => "foo@bar.com"

    assert !u.valid?
  end

  test "mail should have format" do
    u = User.new :auth_source => auth_sources(:one), :login => "foo", :mail => "bar"
    assert !u.valid?
  end

  test "login size should not exceed the 30 characters" do
    u = User.new :auth_source => auth_sources(:one), :login => "a" * 31, :mail => "foo@bar.com"
    assert !u.save
  end

  test "firstname should have the correct format" do
    @user.firstname = "The Riddle?"
    assert !@user.save

    @user.firstname = " _''. - nah"
    assert @user.save
  end

  test "lastname should have the correct format" do
    @user.lastname = "it's the JOKER$$$"
    assert !@user.save

    @user.lastname = " _''. - nah"
    assert @user.save
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
    u = User.create :auth_source => auth_sources(:one), :login => "foo"
    u.mail = "foo" * 20 + "@bar.com"
    assert !u.save
  end

  test "to_label method should return a firstname and the lastname" do
    @user.firstname = "Ali Al"
    @user.lastname = "Salame"
    assert @user.save

    assert_equal "Ali Al Salame", @user.to_label
  end

  test "when try to login if password is empty should return nil" do
    assert_equal nil, User.try_to_login("anything", "")
  end
  # couldn't continue testing the rest of login method cause use auth_source.authenticate, which is not implemented yet

  test "when a user login, his last login time should be updated" do
    user = users(:internal)
    last_login = user.last_login_on
    assert_not_nil User.try_to_login(user.login, "changeme")
    assert_not_equal last_login, User.find(user.id).last_login_on
  end

  test "should not be able to delete the admin account" do
    assert !User.find_by_login("admin").destroy
  end

  test "create_admin should create the admin account" do
    Setting.administrator = 'root@localhost.localdomain'
    ActiveRecord::Base.connection.execute("DELETE FROM users WHERE login='admin'")
    User.create_admin
    assert User.find_by_login("admin")
  end

  test "create_admin should fail when the validation fails" do
    Setting.administrator = 'root@invalid_domain'
    ActiveRecord::Base.connection.execute("DELETE FROM users WHERE login='admin'")
    assert_raise ActiveRecord::RecordInvalid do
      User.create_admin
    end
    #assert User.find_by_login("admin")
  end

  test "create_admin should create the admin account and keep User.current set" do
    User.current = @user
    Setting.administrator = 'root@localhost.localdomain'
    ActiveRecord::Base.connection.execute("DELETE FROM users WHERE login='admin'")
    User.create_admin
    assert User.find_by_login("admin")
    assert_equal User.current, @user
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_users"
      role.permissions = ["#{operation}_users".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  User.new :login => "dummy", :mail => "j@j.com", :auth_source_id => AuthSourceInternal.first.id
    record.password_hash = "asd"
    assert record.save
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  User.new :login => "dummy", :mail => "j@j.com", :auth_source_id => AuthSourceInternal.first.id
    record.password_hash = "asd"
    assert !record.save
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  users(:one)
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  User.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      = users(:one)
    record.login = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  users(:one)
    record.login = "renamed"
    assert !record.save
    assert record.valid?
  end

  test "should not be able to rename the admin account" do
    u = User.find_by_login("admin")
    u.login = "root"
    assert !u.save
  end

  test "email domains with a single word should be allowed" do
    u = User.new :auth_source => auth_sources(:one), :login => "root", :mail => "foo@localhost"
    assert u.save
  end

  test "email with whitespaces should be stripped" do
    u = User.create! :auth_source => auth_sources(:one), :login => "boo", :mail => "b oo@localhost "
    assert_equal u.mail, "boo@localhost"
  end

end
