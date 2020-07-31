require 'test_helper'

# List of valid emails.
def valid_emails_list
  [
    "#{RFauxFactory.gen_alpha}@example.com",
    "#{RFauxFactory.gen_alphanumeric}@example.com",
    "#{RFauxFactory.gen_numeric_string}@example.com",
    "#{RFauxFactory.gen_alphanumeric}+#{RFauxFactory.gen_alphanumeric}@example.com",
    "#{RFauxFactory.gen_alphanumeric}.#{RFauxFactory.gen_alphanumeric}@example.com",
    '"():;"@example.com',
    '!#$%&*+-/=?^`{|}~@example.com',
  ]
end

# List of invalid emails.
def invalid_emails_list
  [
    'foreman@',
    '@foreman',
    '@',
    'Abc.example.com',
    'A@b@c@example.com',
    "#{RFauxFactory.gen_alpha 243}@example.com",
    "#{RFauxFactory.gen_html}@example.com",
    's p a c e s@example.com',
  ]
end

def test_roles
  [
    Role.find_by_name('Manager'),
    Role.find_by_name('View hosts'),
    Role.find_by_name('Edit hosts'),
  ]
end

class UserTest < ActiveSupport::TestCase
  def setup
    User.current = users :admin
    @user = User.create :auth_source => auth_sources(:one), :login => "foo", :mail => "foo@bar.com"
  end

  # Presence
  should validate_presence_of(:login)
  should validate_presence_of(:auth_source_id)
  should validate_uniqueness_of(:login).case_insensitive.
    with_message('already exists')
  # Length
  should validate_length_of(:login).is_at_most(100)
  should validate_length_of(:firstname).is_at_most(50)
  should validate_length_of(:lastname).is_at_most(50)
  should validate_length_of(:mail).is_at_most(254)
  # Format
  should allow_value('').for(:mail).on(:create)
  should allow_value(*valid_emails_list).for(:mail)
  should allow_value('é ô à', "C_r'a-z.y( )<,Na=me;>").for(:firstname)
  should allow_value(*RFauxFactory.gen_strings(1..50, exclude: [:html, :punctuation, :cyrillic, :utf8]).values).for(:firstname)
  should allow_value('é ô à', "C_r'a-z.y( )<,Na=me;>").for(:lastname)
  should allow_value(*RFauxFactory.gen_strings(1..50, exclude: [:html, :punctuation, :cyrillic, :utf8]).values).for(:lastname)
  should allow_value('A$+#APRocky').for(:login)
  should allow_value(*valid_name_list).for(:description)
  should allow_value(*RFauxFactory.gen_strings(1..50, exclude: [:html])).for(:password)
  should_not allow_value('The Riddle?').for(:firstname)
  should_not allow_value(*RFauxFactory.gen_strings(51)).for(:firstname)
  should_not allow_value("it's the JOKER$$$").for(:lastname)
  should_not allow_value(*RFauxFactory.gen_strings(51)).for(:lastname)
  should_not allow_value(*invalid_emails_list).for(:mail)
  should_not allow_value("space #{RFauxFactory.gen_alpha}").for(:login)
  should_not allow_value(RFauxFactory.gen_html).for(:login)
  # Associations
  should have_many(:ssh_keys).dependent(:destroy)

  test 'hooks are defined' do
    expected = [
      'user_created.event.foreman',
      'user_updated.event.foreman',
      'user_destroyed.event.foreman',
    ]

    assert_same_elements expected, User.event_subscription_hooks
  end

  test 'should update with multiple valid descriptions' do
    user = users(:one)
    valid_name_list.each do |description|
      user.description = description
      assert user.valid?, "Can't update user with valid description #{description}"
    end
  end

  test 'should update with multiple valid email' do
    user = users(:one)
    valid_emails_list.each do |mail|
      user.mail = mail
      assert user.valid?, "Can't update user with valid mail #{mail}"
    end
  end

  test 'should update with multiple valid firstname' do
    user = users(:one)
    RFauxFactory.gen_strings(1..50, exclude: [:html, :punctuation, :cyrillic, :utf8]).values.each do |firstname|
      user.firstname = firstname
      assert user.valid?, "Can't update user with valid firstname #{firstname}"
    end
  end

  test 'should update with multiple valid lastname' do
    user = users(:one)
    RFauxFactory.gen_strings(1..50, exclude: [:html, :punctuation, :cyrillic, :utf8]).values.each do |lastname|
      user.lastname = lastname
      assert user.valid?, "Can't update user with valid lastname #{lastname}"
    end
  end

  test 'should update with multiple valid username' do
    user = users(:apiadmin)
    RFauxFactory.gen_strings(1..50, exclude: [:html, :punctuation, :cyrillic, :utf8]).values.each do |login|
      user.login = login
      assert user.valid?, "Can't update user with valid login #{login}"
    end
  end

  test "create user with roles" do
    (1..test_roles.length).each do |index|
      chosen_roles = test_roles[0..index - 1]
      user = FactoryBot.create :user, :roles => chosen_roles
      assert_equal chosen_roles.length + 1, user.roles.length
      assert_equal chosen_roles.push(Role.find_by_name('Default role')).sort, user.roles.sort
    end
  end

  test "update user with roles" do
    user = FactoryBot.create :user
    assert_equal 1, user.roles.length
    (1..test_roles.length).each do |index|
      chosen_roles = test_roles[0..index - 1]
      user.roles = chosen_roles
      assert_equal chosen_roles.length, user.roles.length
      assert_equal chosen_roles, user.roles
    end
  end

  test "mail address is optional on creation" do
    assert_valid FactoryBot.build_stubbed(:user, :mail => nil)
  end

  test "mail is optional if mail is currently nil" do
    u = FactoryBot.create(:user, :mail => nil)
    u.firstname = 'Bob'
    assert_valid u
  end

  test "mail is require when mail isn't currently nil" do
    u = FactoryBot.create(:user, :mail => "foo@bar.com")
    u.mail = nil
    refute_valid u, :mail
  end

  test "mail is required for own user" do
    user = FactoryBot.create(:user)
    user.password = nil
    # refute_valid user can check only one field and due to we need to set password to nil after adding current_password field to verify password change
    as_user user do
      refute_valid user, :mail
    end
  end

  test "hidden users don't need mail when updating" do
    u = User.anonymous_admin
    u.firstname = 'Bob'
    assert_valid u
  end

  test 'login should also be unique across usergroups' do
    Usergroup.expects(:where).with(:name => 'foo').returns(['fakeusergroup'])
    u = FactoryBot.build_stubbed(:user, :auth_source => auth_sources(:one),
                                 :login => "foo", :mail => "foo@bar.com")
    refute u.valid?
    assert_includes u.errors.full_messages, 'A user group already exists with this name'
  end

  test 'external login should be unique across usergroups' do
    Usergroup.expects(:where).with(:name => 'foo').returns(['fakeusergroup'])
    u = FactoryBot.build_stubbed(:user, :auth_source => auth_sources(:external),
                                 :login => "foo", :mail => "foo@bar.com")
    refute u.valid?
    assert_includes u.errors.full_messages, 'A user group already exists with this name'
  end

  test 'hidden login should be unique across usergroups' do
    Usergroup.expects(:where).with(:name => 'foo').returns(['fakeusergroup'])
    u = FactoryBot.build_stubbed(:user, :auth_source => auth_sources(:hidden),
                                 :login => "foo", :mail => "foo@bar.com")
    refute u.valid?
    assert_includes u.errors.full_messages, 'A user group already exists with this name'
  end

  test "user should login case insensitively" do
    user = User.new :auth_source => auth_sources(:internal), :login => "user", :mail => "foo1@bar.com", :password => "foo"
    assert user.save!
    assert_equal user, User.try_to_login("USER", "foo")
  end

  test "user login should be case aware" do
    user = User.new :auth_source => auth_sources(:one), :login => "User", :mail => "foo1@bar.com", :password => "foo"
    assert user.save
    assert_equal user.login, "User"
    assert_equal user.lower_login, "user"
  end

  test "mail should have format" do
    refute User.new(:auth_source => auth_sources(:one), :login => "foo", :mail => "bar").valid?
  end

  test "to_label method should return a firstname and the lastname" do
    @user.firstname = "Ali Al"
    @user.lastname = "Salame"
    assert @user.save

    assert_equal "Ali Al Salame", @user.to_label
  end

  test "new internal user gets welcome mail" do
    ActionMailer::Base.deliveries = []
    Setting[:send_welcome_email] = true
    User.create :auth_source => auth_sources(:internal), :login => "welcome", :mail => "foo@example.com", :password => "qux", :mail_enabled => true
    mail = ActionMailer::Base.deliveries.detect { |delivery| delivery.subject =~ /Welcome to Foreman/ }
    assert mail
    assert_match /Username/, mail.body.encoded
  end

  test "other auth sources don't get welcome mail" do
    Setting[:send_welcome_email] = true
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      User.create :auth_source => auth_sources(:one), :login => "welcome", :mail => "foo@bar.com", :password => "qux"
    end
  end

  context "try to login" do
    test "when password is empty should return nil" do
      assert_nil User.try_to_login("anything", "")
    end

    test ".try_to_login on unknown user should return nil" do
      User.expects(:try_to_auto_create_user).with('unknown user account', 'secret')
      refute User.try_to_login('unknown user account', 'secret')
    end

    test ".try_to_login and failing AuthSource should return nil" do
      u = FactoryBot.create(:user)
      AuthSourceInternal.any_instance.expects(:authenticate).with(u.login, 'password').returns(nil)
      refute User.try_to_login(u.login, 'password')
    end

    test ".try_to_login should return user on successful login" do
      u = FactoryBot.create(:user)
      assert_equal u, User.try_to_login(u.login, 'password')
    end

    test "updates usergroups on login" do
      AuthSourceLdap.any_instance.stubs(:authenticate).returns({})
      AuthSourceLdap.any_instance.expects(:update_usergroups).returns(true)
      User.try_to_login("foo", "password")
    end

    context "ldap attributes" do
      setup do
        AuthSourceLdap.any_instance.stubs(:update_usergroups).returns(true)
      end

      test "ldap user attribute should be updated when not blank (firstname)" do
        AuthSourceLdap.any_instance.stubs(:authenticate).returns({ :firstname => "Foo" })
        logged_in_user = User.try_to_login("foo", "password")
        assert_equal "Foo", logged_in_user.firstname
      end

      test "ldap user attribute should not be updated when blank (mail)" do
        AuthSourceLdap.any_instance.stubs(:authenticate).returns({ :mail => "" })
        logged_in_user = User.try_to_login("foo", "password")
        assert_equal "foo@bar.com", logged_in_user.mail
      end

      test "ldap user attribute should not be saved in DB on create when invalid format (mail)" do
        attrs = {:firstname => "foo", :mail => "foo#bar", :login => "ldap-user", :auth_source_id => auth_sources(:one).id}
        AuthSourceLdap.any_instance.stubs(:authenticate).returns(attrs)
        user = User.try_to_auto_create_user('foo', 'password')
        assert_equal 'foo#bar', user.mail
        assert user.errors[:mail].present?
        assert_nil user.reload.mail
      end

      test "ldap user attribute should not be saved in DB on create when invalid format (firstname)" do
        attrs = {:firstname => "$%$%%%", :mail => "foo@bar.com", :login => "ldap-user", :auth_source_id => auth_sources(:one).id}
        AuthSourceLdap.any_instance.stubs(:authenticate).returns(attrs)
        user = User.try_to_auto_create_user('foo', 'password')
        assert_equal '$%$%%%', user.firstname
        assert user.errors[:firstname].present?
        assert_nil user.reload.firstname
      end

      test "ldap user attribute should not be saved in DB on login when invalid format (mail)" do
        attrs = {:firstname => "foo", :mail => "foo#bar", :login => "ldap-user", :auth_source_id => auth_sources(:one).id}
        AuthSourceLdap.any_instance.stubs(:authenticate).returns(attrs)
        user = User.try_to_login('foo', 'password')
        assert_equal 'foo#bar', user.mail
        assert user.errors[:mail].present?
        assert_equal 'foo@bar.com', user.reload.mail
      end

      test "ldap user attribute should not be saved in DB on login when invalid format (firstname)" do
        attrs = {:firstname => "$%$%%%", :mail => "foo@bar.com", :login => "ldap-user", :auth_source_id => auth_sources(:one).id}
        AuthSourceLdap.any_instance.stubs(:authenticate).returns(attrs)
        user = User.try_to_login('foo', 'password')
        assert_equal '$%$%%%', user.firstname
        assert user.errors[:firstname].present?
        assert_nil user.reload.firstname
      end

      test 'old avatars can be removed upon login' do
        attrs = { :firstname => "foo", :mail => "foo@bar.com",
                  :login => "ldap-user", :avatar_hash => 'testavatar',
                  :auth_source_id => auth_sources(:one).id }
        AuthSourceLdap.any_instance.stubs(:authenticate).returns(attrs)
        User.any_instance.expects(:avatar_hash).returns('oldhash').at_least_once
        User.try_to_login('foo', 'password')
      end
    end
  end

  def setup_user(operation, type = 'users', search = nil)
    super operation, type, search
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record = User.new :login => "dummy", :mail => "j@j.com",
                      :auth_source_id => AuthSourceInternal.first.id,
                      :organizations => User.current.organizations,
                      :locations => User.current.locations
    record.password_hash = "asd"
    assert record.save
    assert record.valid?
    refute record.new_record?
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
    record = nil
    as_admin do
      create_role = Role.find_by_name 'create_users'
      extra_role = Role.where(:name => "foobar").first_or_create
      record = User.new :login => "dummy", :mail => "j@j.com", :auth_source_id => AuthSourceInternal.first.id,
                        :role_ids => [extra_role.id, create_role.id].map(&:to_s),
                        :organizations => users(:one).organizations, :locations => users(:one).locations
    end
    record.password_hash = "asd"
    refute record.save
    refute record.valid?
    assert_includes record.errors.keys, :role_ids
    assert record.new_record?
  end

  test "non-admin user can delegate roles he has assigned already" do
    setup_user "create"
    create_role          = Role.find_by_name 'create_users'
    record               = User.new(:login => "dummy", :mail => "j@j.com",
                                    :auth_source_id => AuthSourceInternal.first.id,
                                    :role_ids => [create_role.id.to_s],
                                    :organizations => User.current.organizations,
                                    :locations => User.current.locations)
    record.password_hash = "asd"
    assert record.valid?
    assert record.save
    assert_not record.new_record?
  end

  test "admin can set admin flag and set any role" do
    as_admin do
      extra_role           = Role.where(:name => "foobar").first_or_create
      record               = User.new(:login => "dummy", :mail => "j@j.com",
                                      :auth_source_id => AuthSourceInternal.first.id,
                                      :role_ids => [extra_role.id.to_s],
                                      :organizations => User.current.organizations,
                                      :locations => User.current.locations)
      record.password_hash = "asd"
      record.admin         = true
      assert record.save
      assert record.valid?
      assert_not record.new_record?
    end
  end

  test "user cannot assign role he has not assigned himself" do
    extra_role = Role.where(:name => "foobar").first_or_create
    setup_user "edit"
    record = users(:one)
    record.role_ids = [extra_role.id]
    refute record.save
    refute record.valid?
    assert_includes record.errors.keys, :role_ids
  end

  test "user can assign role he has assigned himself" do
    users(:one).roles << Role.find_by_name('Manager')
    setup_user "edit"
    edit_role       = Role.find_by_name 'edit_users'
    record          = users(:one)
    record.role_ids = [edit_role.id]
    assert record.valid?
    assert record.save
  end

  test "user cannot escalate his own roles" do
    extra_role = Role.where(:name => "foobar").first_or_create
    setup_user "edit"
    record = User.current
    record.role_ids = record.role_ids + [extra_role.id]
    refute record.save
    refute record.valid?
  end

  test "admin can add any role" do
    as_admin do
      extra_role      = Role.where(:name => "foobar").first_or_create
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

  context "audits for password change" do
    setup do
      @user = User.find_by_id(FactoryBot.create(:user)) # to clear the value of user.password
    end

    test "audit of password change should be saved redacted" do
      as_admin do
        @user.password = "newpassword"
        assert_valid @user
        assert @user.password_changed?
        assert @user.save
        assert_includes Audit.last.audited_changes, "password"
        assert_equal Audit.last.audited_changes["password"], ["[redacted]", "[redacted]"]
      end
    end

    test "audit of password change should not be saved - due to no password change" do
      as_admin do
        @user.firstname = "Johnny"
        assert_valid @user
        refute @user.password_changed?
        assert @user.save
        assert_includes Audit.last.audited_changes, "firstname"
        refute_includes Audit.last.audited_changes, "password"
      end
    end
  end

  test "user can save user if he does not change roles" do
    setup_user "edit"
    record = users(:two)
    record.organizations = User.current.organizations
    record.locations = User.current.locations
    assert record.save
  end

  test "user cannot set admin password" do
    setup_user "edit"
    record = users(:admin)
    record.password = "123332211"
    assert_not record.valid?
    assert_includes record.errors.keys, :password
  end

  test "should be able to remove the admin flag when another admin exists" do
    u = FactoryBot.create(:user, :with_mail, :admin => true)
    u.admin = false
    assert_valid u
  end

  test "should not be able to remove the admin flag from the last admin account" do
    User.unscoped.except_hidden.only_admin.where('login <> ?', users(:apiadmin).login).destroy_all
    u = users(:apiadmin)
    u.admin = false
    refute_valid u, :admin, /last admin account/
  end

  test "should not be able to destroy the last admin account" do
    User.unscoped.except_hidden.only_admin.where('login <> ?', users(:apiadmin).login).destroy_all
    u = users(:apiadmin)
    refute_with_errors u.destroy, u, :base, /last admin account/
  end

  test "should not be able to remove the admin flag from hidden users" do
    u = User.anonymous_admin
    u.admin = false
    refute_valid u, :admin, /internal protected account/
  end

  test "should not be able to destroy hidden users" do
    u = User.anonymous_admin
    refute_with_errors u.destroy, u, :base, /internal admin account/
  end

  test "should not be able to rename hidden users" do
    u = User.anonymous_admin
    u.login = 'no_anonymity_for_you'
    refute_valid u, :login, /internal protected account/
  end

  test "email domains with a single word should be allowed" do
    u = User.new :auth_source => auth_sources(:one), :login => "root", :mail => "foo@localhost"
    assert u.save
  end

  test "email with whitespaces should be stripped" do
    user = User.create! :auth_source => auth_sources(:one), :login => "boo", :mail => " boo@localhost "
    assert_equal user.mail, "boo@localhost"
  end

  test "email should not have special characters outside of quoted string format" do
    user = User.new :auth_source => auth_sources(:one), :login => "boo", :mail => "specialchars():;@example.com"
    refute user.save
  end

  test "email with special characters in quoted string format allowed" do
    user = User.new :auth_source => auth_sources(:one), :login => "boo", :mail => '"specialchars():;"@example.com'
    assert user.save
  end

  test "user that is admin #can_assign? any role" do
    user = users(:one)
    extra_role = Role.where(:name => "foobar").first_or_create
    user.stub :admin?, true do
      assert user.can_assign?([extra_role.id])
    end
  end

  test "admin #can_change_admin_flag?" do
    as_admin do
      assert User.current.can_change_admin_flag?
    end
  end

  test "non admin user #can_assign? only his assigned roles" do
    user = users(:one)
    foobar = Role.where(:name => "foobar").first_or_create
    barfoo = Role.where(:name => "barfoo").first_or_create
    user.roles << foobar

    assert user.can_assign?([foobar.id])
    refute user.can_assign?([foobar.id, barfoo.id])
    refute user.can_assign?([barfoo.id])
    assert user.can_assign?([])
  end

  test "role_ids change detection" do
    user   = users(:one)
    foobar = Role.where(:name => "foobar").first_or_create
    barfoo = Role.where(:name => "barfoo").first_or_create
    user.roles << foobar

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
    foobar = Role.where(:name => "foobar").first_or_create
    Role.where(:name => "barfoo").first_or_create
    user.roles << foobar

    user.role_ids = []
    assert_empty user.roles
  end

  test "role_ids can be nil resulting in no role" do
    user   = users(:one)
    foobar = Role.where(:name => "foobar").first_or_create
    Role.where(:name => "barfoo").first_or_create
    user.roles << foobar

    user.role_ids = nil
    assert_empty user.roles
  end

  test "admin? detection for user admin flag" do
    admin = FactoryBot.build_stubbed(:user, :admin => true)
    assert admin.admin?, 'user admin flag was missed'
  end

  test "admin? detection for group admin flag" do
    admin = FactoryBot.build_stubbed(:user)
    g1 = FactoryBot.build_stubbed(:usergroup)
    g2 = FactoryBot.build_stubbed(:usergroup, :admin => true)
    admin.cached_usergroups = [g1, g2]
    assert admin.admin?, 'group admin flag was missed'
  end

  test "admin? is false if no flag is enabled" do
    admin = FactoryBot.build_stubbed(:user)
    g1 = FactoryBot.build_stubbed(:usergroup)
    g2 = FactoryBot.build_stubbed(:usergroup)
    admin.cached_usergroups = [g1, g2]
    refute admin.admin?
  end

  test "admin can assign arbitrary taxonomies" do
    as_admin do
      user = FactoryBot.build(:user)
      org1 = FactoryBot.create(:organization)
      org2 = FactoryBot.create(:organization)
      user.organization_ids = [org1.id, org2.id]
      assert user.save
    end
  end

  test "user can set only subset of his taxonomies" do
    # superset, one of two, another of two, both
    org1 = FactoryBot.create(:organization)
    org2 = FactoryBot.create(:organization)
    org3 = FactoryBot.create(:organization)
    loc1 = FactoryBot.create(:location)

    user = FactoryBot.build(:user)
    user.organizations = [org1, org2]
    user.locations = [loc1]
    user.roles << Role.find_by_name('Manager')
    user.save
    Organization.expects(:authorized).with('assign_organizations', Organization).returns(Organization.where(:id => [org1, org2])).times(4)
    Location.expects(:authorized).with('assign_locations', Location).returns(Location.where(:id => [loc1])).times(4)

    as_user user do
      # org subset
      new_user = FactoryBot.build(:user)
      new_user.organization_ids = [org1.id]
      new_user.location_ids = [loc1.id]
      assert new_user.save

      # org subset
      new_user = FactoryBot.build(:user)
      new_user.organization_ids = [org2.id]
      new_user.location_ids = [loc1.id]
      assert new_user.save

      # org same set
      new_user = FactoryBot.build(:user)
      new_user.organization_ids = [org1.id, org2.id]
      new_user.location_ids = [loc1.id]
      assert new_user.save

      # org superset
      new_user = FactoryBot.build(:user)
      new_user.organization_ids = [org1.id, org3.id]
      new_user.location_ids = [loc1.id]
      refute new_user.save
      assert_not_empty new_user.errors[:organization_ids]
    end
  end

  test "user can't set empty taxonomies set if he's assigned to some" do
    org1 = FactoryBot.create(:organization)
    user = FactoryBot.create(:user, :organizations => [org1], :locations => [])

    as_user(user) do
      # empty set
      new_user = FactoryBot.build(:user, :organizations => [], :locations => [])
      refute new_user.valid?
      assert_not_empty new_user.errors[:organization_ids]
      assert_empty new_user.errors[:location_ids]
    end
  end

  context "find_or_create_external_user" do
    not_existing_user_login = 'not_existing_user'
    not_existing_auth_source = 'new_external_source'

    context "internal or not existing AuthSource" do
      test 'existing user' do
        assert_difference('User.count', 0) do
          login = users(:one).login
          assert_equal User.find_or_create_external_user({:login => login}, nil),
            User.find_by_login(login)
        end
      end

      test 'not existing user without auth source specified' do
        assert_difference('User.count', 0) do
          user = User.find_or_create_external_user({:login => not_existing_user_login}, nil)
          assert user.nil?
        end
      end

      test 'not existing user with non existing auth source' do
        assert_difference('User.count', 1) do
          assert_difference('AuthSource.count', 1) do
            user = User.find_or_create_external_user({:login => not_existing_user_login},
              not_existing_auth_source)
            assert_equal user, User.find_by_login(not_existing_user_login)

            new_source = AuthSourceExternal.find_by_name(not_existing_auth_source)
            assert_equal new_source.name, user.auth_source.name
          end
        end
      end
    end

    context "existing AuthSource" do
      setup do
        @apache_source = AuthSourceExternal.where(:name => 'apache_module').first_or_create
      end

      test "not existing" do
        assert_difference('User.count', 1) do
          assert_difference('AuthSource.count', 0) do
            assert_equal User.find_or_create_external_user(
              {:login => not_existing_user_login}, @apache_source.name),
              User.find_by_login(not_existing_user_login)
          end
        end
      end

      test "not existing with attributes" do
        created_user = User.find_or_create_external_user(
          {:login => not_existing_user_login,
           :mail => 'foobar@example.com',
           :firstname => 'Foo',
           :lastname => 'Bar'}, @apache_source.name)
        assert_equal not_existing_user_login, created_user.login
        assert_equal @apache_source.name, created_user.auth_source.name
        assert_equal 'foobar@example.com', created_user.mail
        assert_equal 'Foo', created_user.firstname
        assert_equal 'Bar', created_user.lastname
      end

      context 'with external user groups' do
        setup do
          @user      = FactoryBot.create(:user,               :auth_source => @apache_source)
          @external  = FactoryBot.create(:external_usergroup, :auth_source => @apache_source)
          @usergroup = FactoryBot.create(:usergroup)
        end

        test "existing user groups that are assigned" do
          @external.update(:usergroup => @usergroup, :name => @usergroup.name)
          created_user = User.find_or_create_external_user(
            {:login => not_existing_user_login, :groups => [@external.name, 'notexistentexternal']},
            @apache_source.name)
          assert_equal [@usergroup], created_user.usergroups
        end
      end
    end
  end

  context 'auto create users' do
    setup do
      ldap_attrs = { :firstname => "Foo", :lastname => "Bar", :mail => "baz@qux.com",
                     :login => 'FoOBaR' }
      AuthSourceLdap.any_instance.stubs(:authenticate).returns(ldap_attrs)
      @ldap_server = AuthSource.find_by_name("ldap-server")
    end

    context 'success' do
      setup do
        AuthSourceLdap.any_instance.expects(:update_usergroups).
            with('FoOBaR').returns(true)
      end

      test "enabled on-the-fly registration" do
        @ldap_server.update_attribute(:onthefly_register, true)
        assert_difference("User.count", 1) do
          assert User.try_to_auto_create_user('foobar', 'fakepass')
        end
      end

      test "use LDAP login attribute as login" do
        created_user = User.try_to_auto_create_user('foobar', 'fakepass')
        assert_equal created_user.login, "FoOBaR"
      end

      test 'taxonomies from the auth source are inherited' do
        @ldap_server.organizations = [taxonomies(:organization1)]
        @ldap_server.locations = [taxonomies(:location1)]
        created_user = User.try_to_auto_create_user('foobar', 'fakepass')
        assert_equal @ldap_server.organizations.to_a,
          created_user.organizations.to_a
        assert_equal @ldap_server.locations.to_a,
          created_user.locations.to_a
      end
    end

    test "disabled on-the-fly registration" do
      @ldap_server.update_attribute(:onthefly_register, false)
      assert_difference("User.count", 0) do
        refute User.try_to_auto_create_user('foobar', 'fakepass')
      end
    end
  end

  context "editing self?" do
    # A regular setup block would run before the global setup
    # leaving User.current = users :admin
    def editing_self_helper
      User.current = users(:one)
      @options = {:controller => "users", :action => "edit", :id => User.current.id}
    end

    test "edit self" do
      editing_self_helper
      assert User.current.editing_self?(@options)
    end

    test "update self" do
      editing_self_helper
      @options[:action] = "update"
      assert User.current.editing_self?(@options)
    end

    test "update other user" do
      editing_self_helper
      @options[:id] = users(:two).id
      refute User.current.editing_self?(@options)
    end

    test "update through other controller" do
      editing_self_helper
      @options[:controller] = "hosts"
      @options[:id] = User.current.id
      refute User.current.editing_self?(@options)
    end
  end

  test "#can? for admin" do
    Authorizer.any_instance.stubs(:can?).returns(false)
    u = FactoryBot.build_stubbed(:user, :admin => true)
    assert u.can?(:view_hosts_or_whatever_you_ask)
  end

  test "#can? for not admin" do
    Authorizer.any_instance.stubs(:can?).returns('authorizer was asked')
    u = FactoryBot.build_stubbed(:user)
    assert_equal 'authorizer was asked', u.can?(:view_hosts_or_whatever_you_ask)
  end

  test 'default taxonomy inclusion validator' do
    users(:one).default_location = taxonomies(:location2)
    users(:one).default_organization = taxonomies(:organization2)

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
    users(:one).roles << Role.find_by_name('Manager')
    as_user :one do
      # User 'one' contains location1 already
      in_taxonomy :location1 do
        assert child = Location.create!(:name => 'child location', :parent_id => Location.current.id)
        assert_equal [Location.current.id, child.id].sort, User.current.location_and_child_ids
      end
    end
  end

  test "return organization and child ids for non-admin user" do
    users(:one).roles << Role.find_by_name('Manager')
    as_user :one do
      # User 'one' contains organization1 already
      in_taxonomy :organization1 do
        assert child = Organization.create!(:name => 'child organization', :parent_id => Organization.current.id)
        assert_equal [Organization.current.id, child.id].sort, User.current.organization_and_child_ids
      end
    end
  end

  test "my_locations includes locations set to 'all users'" do
    user = FactoryBot.create(:user)
    location = FactoryBot.create(:location)
    refute_includes user.my_locations, location
    location.ignore_types = ['User']
    location.save!
    assert_includes user.my_locations, location
  end

  test "my_organizations includes organizations set to 'all users'" do
    user = FactoryBot.create(:user)
    organization = FactoryBot.create(:organization)
    refute_includes user.my_organizations, organization
    organization.ignore_types = ['User']
    organization.save!
    assert_includes user.my_organizations, organization
  end

  test "chaging hostgroup should update cache" do
    u = FactoryBot.create(:user)
    g1 = FactoryBot.create(:usergroup)
    g2 = FactoryBot.create(:usergroup)
    assert_empty u.usergroups
    assert_empty u.cached_usergroups
    u.usergroups = [g1, g2]
    u.reload
    assert_equal [g1.id, g2.id].sort, u.cached_usergroup_ids.sort

    u.usergroups = [g2]
    u.reload
    assert_equal [g2.id].sort, u.cached_usergroup_ids.sort

    u.usergroups = [g1]
    u.reload
    assert_equal [g1.id].sort, u.cached_usergroup_ids.sort

    u.usergroups = []
    u.reload
    assert_empty u.cached_usergroups
  end

  test 'default taxonomy inclusion validator takes into account inheritance' do
    Location.create(:parent => Location.first, :name => 'inherited_loc')
    Organization.create(:parent => Organization.first, :name => 'inherited_org')
    users(:one).update_attribute(:locations, [Location.first])
    users(:one).update_attribute(:organizations, [Organization.first])
    users(:one).default_location     = Location.find_by_name('inherited_loc')
    users(:one).default_organization = Organization.find_by_name('inherited_org')

    assert users(:one).valid?
  end

  test "#matching_password? succeeds if password matches" do
    u = FactoryBot.build_stubbed(:user)
    assert_valid u
    assert u.matching_password?('password')
  end

  test "#matching_password? succeeds if password matches with higher cost" do
    Setting[:bcrypt_cost] = 15
    user = FactoryBot.build_stubbed(:user)
    assert_valid user
    assert user.matching_password?('password')
    Setting[:bcrypt_cost] = 10
  end

  test "#matching_password? fails if password does not match" do
    u = FactoryBot.build_stubbed(:user)
    assert_valid u
    refute u.matching_password?('wrong password')
  end

  test "#matching_password? upgrades from SHA1 to BCrypt" do
    hasher = Foreman::PasswordHash.new(:sha1)
    u = FactoryBot.build_stubbed(:user)
    u.password_salt = hasher.generate_salt(0)
    u.password_hash = hasher.hash_secret('password', u.password_salt)
    u.expects(:upgrade_password).with('password')
    assert u.matching_password?('password')
  end

  test "#matching_password? does not upgrade from BCrypt to BCrypt for no reason" do
    hasher = Foreman::PasswordHash.new(:bcrypt)
    u = FactoryBot.build_stubbed(:user)
    u.password_salt = hasher.generate_salt(5)
    u.password_hash = hasher.hash_secret('password', u.password_salt)
    u.expects(:upgrade_password).never
    assert u.matching_password?('password')
  end

  test ".except_hidden doesn't return any hidden users" do
    assert User.unscoped.where(:auth_source_id => AuthSourceHidden.first).any?
    User.unscoped.except_hidden.each do |user|
      assert_not_kind_of AuthSourceHidden, user.auth_source
    end
  end

  test "#hidden? for hidden user" do
    assert User.anonymous_admin.hidden?
  end

  test "#hidden? for ordinary user" do
    refute FactoryBot.build_stubbed(:user).hidden?
  end

  test "should not be able to use hidden auth source on other users" do
    u = FactoryBot.build(:user, :auth_source => AuthSourceHidden.first)
    refute_valid u, :auth_source, /permitted/
  end

  context ".random_password" do
    it "should return password" do
      assert_match /\A[a-zA-Z0-9]{16}\z/, User.random_password
    end

    it "should not return ambiguous characters" do
      refute_match /[O0Il1]/, User.random_password(100)
    end
  end

  test ".as_anonymous_admin sets User.current to anonymous admin" do
    User.as_anonymous_admin do
      assert_equal User::ANONYMOUS_ADMIN, User.current.try(:login)
    end
  end

  test ".as throws exception for unknown users" do
    assert_raise(Foreman::Exception) { User.as('unknown_user') }
  end

  test "#ensure_last_admin_is_not_deleted with non-admins" do
    User.unscoped.only_admin.each(&:delete)
    user = users(:one)
    assert user.destroy
    assert user.destroyed?
  end

  test "auto-complete doesn't show hidden users" do
    User.complete_for('login = ').each { |ac| refute_match users(:anonymous).login, ac }
  end

  test 'can search users by role id' do
    # Setup role and assign to user
    role = Role.where(:name => "foobar").first_or_create
    user = users(:one)
    user.role_ids = [role.id]

    users = User.search_for("role_id = #{role.id}")
    assert (users.include? user)
  end

  test 'can search users by usergroup' do
    user = FactoryBot.create(:user, :with_usergroup)
    assert_equal [user], User.search_for("usergroup = #{user.usergroups.first.name}")
  end

  test 'can set valid timezone' do
    timezone = "Fiji"
    user = users(:one)
    user.timezone = timezone
    assert user.valid?
    assert_equal(user.timezone, timezone)
  end

  test 'can not set invalid timezone' do
    user = users(:one)
    user.timezone = "Brno"
    refute user.valid?
  end

  test 'empty timezone is normalized to nil' do
    user = users(:one)
    user.timezone = ''
    assert user.valid?
    user.save
    _(user.timezone).must_be_nil
  end

  test "changing user password as admin without setting current password" do
    user = FactoryBot.create(:user, :mail => "foo@bar.com")
    as_admin do
      user.password = "newpassword"
      assert user.save
    end
  end

  test "changing user's own password with incorrect current password" do
    user = FactoryBot.create(:user, :mail => "foo@bar.com")
    as_user user do
      user.current_password = "hatatitla"
      user.password = "newpassword"
      refute user.valid?
      assert user.errors.messages.has_key? :current_password
    end
  end

  test "changing user's own password with correct current password" do
    user = FactoryBot.create(:user, :password => "password", :mail => "foo@bar.com")
    as_user user do
      user.current_password = "password"
      user.password = "newpassword"
      assert user.save
    end
  end

  test 'creating jwt secret for user' do
    user = FactoryBot.create(:user)
    jwt_secret = user.jwt_secret!

    refute_nil jwt_secret
    assert jwt_secret.persisted?
  end

  describe '#destroy' do
    it 'works for user with two groups' do
      user = users(:one)
      FactoryBot.create_list(:user_usergroup_member, 2, member: user)
      user.reload.destroy
      assert user.destroyed?
    end
  end

  context 'Jail' do
    test 'should allow methods' do
      allowed = [:login, :ssh_keys, :ssh_authorized_keys, :description, :firstname, :lastname, :mail]

      allowed.each do |m|
        assert User::Jail.allowed?(m), "Method #{m} is not available in User::Jail while should be allowed."
      end
    end
  end

  describe '#visible_environments' do
    test 'should show the list of environments visible as admin user' do
      # Admin user sees all environments - including the ones without taxonomies
      assert_equal ['production', 'global_puppetmaster', 'testing'].sort, User.current.visible_environments.sort
    end

    test 'should show the list of environments visible as inherited admin user' do
      User.current = FactoryBot.create(:user, usergroups: [FactoryBot.create(:usergroup, admin: true)]).reload
      assert_equal ['production', 'global_puppetmaster', 'testing'].sort, User.current.visible_environments.sort
    end

    test 'should show the list of environments visible as non-admin user' do
      # Non-admin user only sees environments in a taxonomy at least
      setup_user 'view', 'environments'
      assert_equal ['production'], User.current.visible_environments
    end
  end

  context 'personal access token auth' do
    let(:user) { FactoryBot.create(:user) }
    let(:token) { FactoryBot.create(:personal_access_token, :user => user) }
    let(:token_value) do
      token_value = token.generate_token
      token.save
      token_value
    end
    let(:expired_token) { FactoryBot.create(:personal_access_token, :user => user, :expires_at => 4.weeks.ago) }
    let(:expired_token_value) do
      token_value = expired_token.generate_token
      expired_token.save
      token_value
    end

    context 'api login' do
      test 'user can api login via personal access token' do
        assert_nil token.last_used_at
        assert_equal user, User.try_to_login(user.login, token_value, true)
        assert_not_nil token.reload.last_used_at
      end

      test 'user can not api login with expired personal access token' do
        assert_nil User.try_to_login(user.login, expired_token_value, true)
      end

      test 'token is validated' do
        token
        assert_nil User.try_to_login(user.login, 'invalid', true)
      end
    end

    context 'ui login' do
      test 'user can not ui login via personal access token' do
        assert_nil User.try_to_login(user.login, token_value, false)
      end
    end
  end

  context 'update login' do
    let(:auth_source_ldap) { FactoryBot.create(:auth_source_ldap) }
    let (:user_login) { FactoryBot.create(:user, :locations => [Location.first], :organizations => [Organization.first]) }
    let (:external_user) { FactoryBot.create(:user, :auth_source => auth_source_ldap, :locations => user_login.locations, :organizations => user_login.organizations) }
    let (:external_user_manager) { FactoryBot.create(:user, :auth_source => auth_source_ldap, :locations => user_login.locations, :organizations => user_login.organizations, :roles => [roles(:manager)]) }
    let (:internal_user) { FactoryBot.create(:user, :locations => user_login.locations, :organizations => user_login.organizations, :mail => "foo@bar.com",  :current_password => "password") }
    let (:internal_user_manager) { FactoryBot.create(:user, :locations => user_login.locations, :organizations => user_login.organizations, :roles => [roles(:manager)]) }

    test 'Internal user can update his own login' do
      as_user internal_user do
        internal_user.login = "dummy2"
        internal_user.valid?
        assert internal_user.save
      end
    end

    test 'Internal user with permission can edit other users login' do
      as_user internal_user_manager do
        user_login.login = "dummy2"
        assert user_login.valid?
        assert user_login.save
      end
    end

    test 'Internal user without permission can not edit other user login' do
      as_user internal_user do
        user_login.login = "dummy3"
        assert_not user_login.save
      end
    end

    test 'External user can not edit his own login' do
      as_user external_user do
        external_user.login = "dummy4"
        assert_not external_user.save
      end
    end

    test 'External user login can not be changed' do
      as_user external_user_manager do
        external_user.login = "dummy5"
        assert_not external_user.save
      end
    end
  end

  context 'audit user roles' do
    setup do
      @user = FactoryBot.create(:user, :with_auditing)
      @role = FactoryBot.create(:role)
    end

    test 'should audit when a role is assigned to a user' do
      # Ensure the default role is loaded when creating the audit, Rails 5.2.1 workaround (https://projects.theforeman.org/issues/25602)
      @user.reload

      @user.role_ids = [@role.id]
      @user.save

      recent_audit = @user.audits.last
      audited_changes = recent_audit.audited_changes['role_ids']

      assert audited_changes, 'No audits found for user-roles'
      assert_equal [Role.default.id], audited_changes.first
      assert_equal [@role.id], audited_changes.last
    end

    test 'should audit when a role is removed/de-assigned from a user' do
      @user.role_ids = [@role.id]
      @user.save
      @user.role_ids = []
      @user.save

      recent_audit = @user.audits.last
      audited_changes = recent_audit.audited_changes['role_ids']

      assert audited_changes, 'No audits found for user-roles'
      assert_equal [[@role.id, Role.default.id], []], audited_changes
      assert_empty audited_changes.last
    end

    test 'audit of other properties are not impacted' do
      @user.firstname = 'Bob'
      @user.description = 'The auditor'
      @user.save

      recent_audit = @user.audits.last

      assert recent_audit.audited_changes['firstname']
      assert recent_audit.audited_changes['description']
      assert_nil recent_audit.audited_changes['roles']
    end
  end

  test '#fetch_ids_by_list is case insensitive' do
    user_ids = User.fetch_ids_by_list(['OnE', 'TwO', 'tHREE'])
    assert_equal 2, user_ids.length

    usergroup = FactoryBot.create(:usergroup)
    usergroup.user_ids = user_ids
    usergroup.save

    login_values = usergroup.users.map(&:login).sort

    # users 'one' 'two' are defined in fixtures, 'three' is not defined
    assert_equal ['one', 'two'], login_values
    assert_not_includes login_values, 'tHREE'
  end
end
