# encoding: UTF-8
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

    @user.firstname = "C_r'a-z.y( )<,Na=me;>"
    assert @user.save

    @user.firstname = "é ô à"
    assert @user.save
  end

  test "lastname should have the correct format" do
    @user.lastname = "it's the JOKER$$$"
    assert !@user.save

    @user.lastname = "C_r'a-z.y( )<,Na=me;>"
    assert @user.save

    @user.lastname = "é ô à"
    assert @user.save
  end

  test "firstname should not exceed the 50 characters" do
    @user.firstname = "a" * 51
    assert !@user.save
  end

  test "lastname should not exceed the 50 characters" do
    @user.firstname = "a" * 51
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

  test "ldap user attribute should be updated when not blank" do
    AuthSourceLdap.any_instance.stubs(:authenticate).returns({ :firstname => "Foo" })
    u = User.try_to_login("foo", "password")
    assert_equal u.firstname, "Foo"
  end

  test "ldap user attribute should not be updated when blank" do
    AuthSourceLdap.any_instance.stubs(:authenticate).returns({ :mail => "" })
    u = User.try_to_login("foo", "password")
    assert_equal u.mail, "foo@bar.com"
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
    super operation, "users"
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

  test "role_ids can be empty array which removes all roles" do
    user   = users(:one)
    foobar = Role.find_or_create_by_name :name => "foobar"
    barfoo = Role.find_or_create_by_name :name => "barfoo"
    user.roles<< foobar

    user.role_ids = []
    assert_empty user.roles
  end

  test "role_ids can be nil resulting in no role" do
    user   = users(:one)
    foobar = Role.find_or_create_by_name :name => "foobar"
    barfoo = Role.find_or_create_by_name :name => "barfoo"
    user.roles<< foobar

    user.role_ids = nil
    assert_empty user.roles
  end

  test "admin? detection for user admin flag" do
    admin = FactoryGirl.build(:user, :admin => true)
    assert admin.admin?, 'user admin flag was missed'
  end

  test "admin? detection for group admin flag" do
    admin = FactoryGirl.build(:user)
    g1 = FactoryGirl.build(:usergroup)
    g2 = FactoryGirl.build(:usergroup, :admin => true)
    admin.cached_usergroups = [g1, g2]
    assert admin.admin?, 'group admin flag was missed'
  end

  test "admin? is false if no flag is enabled" do
    admin = FactoryGirl.build(:user)
    g1 = FactoryGirl.build(:usergroup)
    g2 = FactoryGirl.build(:usergroup)
    admin.cached_usergroups = [g1, g2]
    refute admin.admin?
  end

  test ".find_or_create_external_user" do
    count = User.count
    # existing user
    assert User.find_or_create_external_user({:login => users(:one).login}, nil)
    assert_equal count, User.count

    # not existing user without auth source specified
    assert !User.find_or_create_external_user({:login => 'not_existing_user'}, nil)
    assert_equal count, User.count

    # not existing user with existing AuthSource
    apache_source = AuthSourceExternal.find_or_create_by_name('apache_module')
    source_count = AuthSource.count
    assert User.find_or_create_external_user({:login => 'not_existing_user'}, apache_source.name)
    assert_equal count + 1, User.count
    assert_equal source_count, AuthSource.count
    user = User.find_by_login('not_existing_user')
    assert_equal apache_source.name, user.auth_source.name

    count = User.count
    assert User.find_or_create_external_user({:login => 'not_existing_user_2'}, 'new_external_source')
    assert_equal count + 1, User.count
    assert_equal source_count + 1, AuthSource.count
    user = User.find_by_login('not_existing_user_2')
    new_source = AuthSourceExternal.find_by_name('new_external_source')
    assert_equal new_source.name, user.auth_source.name

    # with other attributes which gets saved as well
    apache_source = AuthSourceExternal.find_or_create_by_name('apache_module')
    assert User.find_or_create_external_user({:login => 'not_existing_user_3',
                                              :mail => 'foobar@example.com',
                                              :firstname => 'Foo',
                                              :lastname => 'Bar'},
                                             apache_source.name)
    user = User.find_by_login('not_existing_user_3')
    assert_equal 'foobar@example.com', user.mail
    assert_equal 'Foo', user.firstname
    assert_equal 'Bar', user.lastname

    # with existing user groups that are assigned
    apache_source = AuthSourceExternal.find_or_create_by_name('apache_module')
    usergroup = FactoryGirl.create :usergroup
    external = FactoryGirl.create :external_usergroup, :usergroup => usergroup,
                                  :auth_source => apache_source,
                                  :name => usergroup.name
    assert User.find_or_create_external_user({:login => 'not_existing_user_4',
                                              :groups => [external.name, 'does-not-exists-for-sure-123']},
                                             apache_source.name)
    user = User.find_by_login('not_existing_user_4')
    assert_equal [usergroup], user.usergroups
  end

  test ".find_or_create_external_user updates external groups" do
    apache_source = AuthSourceExternal.find_or_create_by_name('apache_module')
    user = FactoryGirl.create(:user, :auth_source => apache_source)
    external1 = FactoryGirl.create(:external_usergroup, :auth_source => apache_source)
    external2 = FactoryGirl.create(:external_usergroup, :auth_source => apache_source)
    usergroup = FactoryGirl.create(:usergroup)
    user.usergroups << [external1.usergroup, usergroup]

    refute_equal 'foo@example.com', user.mail
    assert User.find_or_create_external_user({:login => user.login,
                                              :groups => [external2.name],
                                              :mail => 'foo@example.com'},
                                             apache_source.name)
    user.reload
    assert_includes user.usergroups, external2.usergroup
    assert_includes user.usergroups, usergroup
    assert_equal 'foo@example.com', user.mail
  end

  test ".try_to_auto_create_user" do
    AuthSourceLdap.any_instance.stubs(:authenticate).returns({ :firstname => "Foo", :lastname => "Bar", :mail => "baz@qux.com" })

    ldap_server = AuthSource.find_by_name("ldap-server")

    # AuthSource that allows onthefly registration
    count = User.count
    ldap_server.update_attribute(:onthefly_register, true)
    assert User.try_to_auto_create_user('non_existing_user_1','password')
    assert_equal count + 1, User.count

    # AuthSource that forbids onthefly registration
    count = User.count
    ldap_server.update_attribute(:onthefly_register, false)
    assert !User.try_to_auto_create_user('non_existing_user_2','password')
    assert_equal count, User.count

  end

  test 'user should allow editing self?' do
    User.current = users(:one)

    # edit self
    options = {:controller => 'users', :action => 'edit', :id => User.current.id}
    assert User.current.editing_self?(options)

    # update self
    options = {:controller => 'users', :action => 'update', :id => User.current.id}
    assert User.current.editing_self?(options)

    # update someone else
    options = {:controller => 'users', :action => 'update', :id => users(:two).id}
    assert_not User.current.editing_self?(options)

    # update for another controller
    options = {:controller => 'hosts', :action => 'update', :id => User.current.id}
    assert_not User.current.editing_self?(options)
  end

  test "#can? for admin" do
    Authorizer.any_instance.stubs(:can?).returns(false)
    u = FactoryGirl.build(:user, :admin => true)
    assert u.can?(:view_hosts_or_whatever_you_ask)
  end

  test "#can? for not admin" do
    Authorizer.any_instance.stubs(:can?).returns('authorizer was asked')
    u = FactoryGirl.build(:user)
    assert_equal 'authorizer was asked', u.can?(:view_hosts_or_whatever_you_ask)
  end

  test 'default taxonomy inclusion validator' do
    users(:one).default_location = Location.first
    users(:one).default_organization = Organization.first

    refute users(:one).valid?
    assert users(:one).errors.messages.has_key? :default_location
    assert users(:one).errors.messages.has_key? :default_organization
  end

  test 'any taxonomy works as default taxonomy for admins' do
    users(:one).update_attribute(:admin, true)
    users(:one).default_location = Location.first

    assert users(:one).valid?
  end

  test "return location and child ids for non-admin user" do
    as_user :one do
      in_taxonomy :location1 do
        assert User.current.locations << Location.current
        assert child = Location.create!(:name => 'child location', :parent_id => Location.current.id)
        assert_equal [Location.current.id, child.id].sort, User.current.location_and_child_ids
      end
    end
  end

  test "return organization and child ids for non-admin user" do
    as_user :one do
      in_taxonomy :organization1 do
        assert User.current.organizations << Organization.current
        assert child = Organization.create!(:name => 'child organization', :parent_id => Organization.current.id)
        assert_equal [Organization.current.id, child.id].sort, User.current.organization_and_child_ids
      end
    end
  end

#  Uncomment after users get access to children taxonomies of their current taxonomies.
#
#  test 'default taxonomy inclusion validator takes into account inheritance' do
#    inherited_location     = Location.create(:parent => Location.first, :name => 'inherited_loc')
#    inherited_organization = Organization.create(:parent => Organization.first, :name => 'inherited_org')
#    users(:one).update_attribute(:locations, [Location.first])
#    users(:one).update_attribute(:organizations, [Organization.first])
#    users(:one).default_location     = Location.find_by_name('inherited_loc')
#    users(:one).default_organization = Organization.find_by_name('inherited_org')
#
#    assert users(:one).valid?
#  end

end
