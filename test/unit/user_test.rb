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

  test "login size should not exceed the 100 characters" do
    u = User.new :auth_source => auth_sources(:one), :login => "a" * 101, :mail => "foo@bar.com"
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
    User.delete(User.admin.id)
    User.create_admin
    assert User.find_by_login("admin")
  end

  test "create_admin should fail when the validation fails" do
    Setting.administrator = 'root@invalid_domain'
    User.delete(User.admin.id)
    assert_raise ActiveRecord::RecordInvalid do
      User.create_admin
    end
  end

  test "create_admin should create the admin account and keep User.current set" do
    User.current = @user
    Setting.administrator = 'root@localhost.localdomain'
    User.delete(User.admin.id)
    User.create_admin
    assert User.find_by_login("admin")
    assert_equal User.current, @user
  end

  test "#admin should create new one if it's missing" do
    old_admin = User.admin
    assert old_admin.delete
    assert_nil User.find_by_login(old_admin.login)
    assert_present User.admin
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

  test "non-admin user with create permissions should not be able to create admin" do
    setup_user "create"
    record               = User.new :login => "dummy", :mail => "j@j.com", :auth_source_id => AuthSourceInternal.first.id
    record.password_hash = "asd"
    record.admin         = true
    assert_not record.save
    assert_not record.valid?
    assert_includes record.errors.keys, :admin
    assert record.new_record?
  end

  test "non-admin user can't assign roles he does not have himself" do
    setup_user "create"
    create_role          = Role.find_by_name 'create_users'
    extra_role           = Role.find_or_create_by_name :name => "foobar"
    record               = User.new :login    => "dummy", :mail => "j@j.com", :auth_source_id => AuthSourceInternal.first.id,
                                    :role_ids => [extra_role.id, create_role.id].map(&:to_s)
    record.password_hash = "asd"
    assert_not record.save
    assert_not record.valid?
    assert_includes record.errors.keys, :role_ids
    assert record.new_record?
  end

  test "non-admin user can delegate roles he has assigned already" do
    setup_user "create"
    create_role          = Role.find_by_name 'create_users'
    record               = User.new :login    => "dummy", :mail => "j@j.com", :auth_source_id => AuthSourceInternal.first.id,
                                    :role_ids => [create_role.id.to_s]
    record.password_hash = "asd"
    assert record.valid?
    assert record.save
    assert_not record.new_record?
  end

  test "admin can set admin flag and set any role" do
    as_admin do
      extra_role           = Role.find_or_create_by_name :name => "foobar"
      record               = User.new :login    => "dummy", :mail => "j@j.com", :auth_source_id => AuthSourceInternal.first.id,
                                      :role_ids => [extra_role.id].map(&:to_s)
      record.password_hash = "asd"
      record.admin         = true
      assert record.save
      assert record.valid?
      assert_not record.new_record?
    end
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

  test "user cannot assign role he has not assigned himself" do
    setup_user "edit"
    extra_role      = Role.find_or_create_by_name :name => "foobar"
    record          = users(:one)
    record.role_ids = [extra_role.id]
    assert_not record.save
    assert_not record.valid?
    assert_includes record.errors.keys, :role_ids
  end

  test "user can assign role he has assigned himself" do
    setup_user "edit"
    edit_role       = Role.find_by_name 'edit_users'
    record          = users(:one)
    record.role_ids = [edit_role.id]
    assert record.valid?
    assert record.save
  end

  test "user cannot escalate his own roles" do
    setup_user "edit"
    extra_role      = Role.find_or_create_by_name :name => "foobar"
    record = User.current
    record.role_ids = record.role_ids + [extra_role.id]
    refute record.save
    refute record.valid?
  end

  test "admin can add any role" do
    as_admin do
      extra_role      = Role.find_or_create_by_name :name => "foobar"
      record          = users(:one)
      record.role_ids = [extra_role.id]
      assert record.valid?
      assert record.save
    end
  end

  test "admin can update admin flag" do
    as_admin do
      record       = users(:one)
      record.admin = true
      assert record.valid?
      assert record.save
    end
  end

  test "user can not update admin flag" do
    setup_user "edit"
    record       = users(:two)
    record.admin = true
    assert_not record.save
    assert_not record.valid?
    assert_includes record.errors.keys, :admin
  end

  test "user can save user if he does not change roles" do
    setup_user "edit"
    record = users(:two)
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

  test "should not be able to remove the admin flag from the admin account" do
    u = User.find_by_login("admin")
    u.admin = false
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

  test "use that can change admin flag #can_assign? any role" do
    user       = users(:one)
    extra_role = Role.find_or_create_by_name :name => "foobar"
    user.stub :can_change_admin_flag?, true do
      assert user.can_assign?([extra_role.id])
    end
  end

  test "admin #can_change_admin_flag?" do
    as_admin do
      assert User.current.can_change_admin_flag?
    end
  end

  test "non admin user #can_assign? only his assigned roles" do
    user   = users(:one)
    foobar = Role.find_or_create_by_name :name => "foobar"
    barfoo = Role.find_or_create_by_name :name => "barfoo"
    user.roles<< foobar

    assert user.can_assign?([foobar.id])
    refute user.can_assign?([foobar.id, barfoo.id])
    refute user.can_assign?([barfoo.id])
    assert user.can_assign?([])
  end

  test "role_ids change detection" do
    user   = users(:one)
    foobar = Role.find_or_create_by_name :name => "foobar"
    barfoo = Role.find_or_create_by_name :name => "barfoo"
    user.roles<< foobar

    user.role_ids = [foobar.id]
    refute user.role_ids_changed?

    user.role_ids = [foobar.id, barfoo.id]
    assert user.role_ids_changed?
    assert_equal user.role_ids_was, [foobar.id]

    # order does not matter
    user.role_ids = [barfoo.id, foobar.id]
    refute user.role_ids_changed?
    user.role_ids = [foobar.id, barfoo.id]
    refute user.role_ids_changed?
    assert_equal user.role_ids_was, [foobar.id, barfoo.id]
  end

end
