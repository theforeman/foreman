require 'test_helper'

class UsergroupTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  test "usergroups should be creatable" do
    assert FactoryBot.build_stubbed(:usergroup).valid?
  end

  test "name is unique across user as well as usergroup" do
    User.expects(:find_by).with(:login => 'usergroup1').returns(['fakeuser'])
    usergroup = FactoryBot.build_stubbed(:usergroup, :name => 'usergroup1')
    refute usergroup.valid?
  end

  context "with new usergroup" do
    subject { Usergroup.new(:name => 'test') }
    should validate_uniqueness_of(:name)
  end
  should validate_presence_of(:name)
  should have_many(:usergroup_members).dependent(:destroy)
  should have_many(:users).dependent(:destroy)
  should_not allow_value(*invalid_name_list).for(:name)
  should allow_value(*valid_name_list).for(:name)
  should have_many(:cached_users)
  should have_many(:cached_usergroups)

  test 'should not update with multiple invalid names' do
    usergroup = FactoryBot.create(:usergroup)
    invalid_name_list.each do |name|
      usergroup.name = name
      refute usergroup.valid?, "Can update usergroup with invalid name #{name}"
      assert_includes usergroup.errors.keys, :name
    end
  end

  test 'should update with multiple valid names' do
    usergroup = FactoryBot.create(:usergroup)
    valid_name_list.each do |name|
      usergroup.name = name
      assert usergroup.valid?, "Can't update usergroup with valid name #{name}"
    end
  end

  test 'should create with valid role' do
    valid_name_list.each do |name|
      role = FactoryBot.create(:role, :name => name)
      usergroup = FactoryBot.build(:usergroup, :role_ids => [role.id])
      assert usergroup.valid?, "Can't create usergroup with valid role #{role}"
      assert_equal 1, usergroup.roles.length
      assert_equal name, usergroup.roles.first.name
    end
  end

  test 'should create with valid user' do
    RFauxFactory.gen_strings(1..50, exclude: [:html, :punctuation, :cyrillic, :utf8]).values.each do |login|
      user = FactoryBot.create(:user, :login => login)
      usergroup = FactoryBot.build(:usergroup, :user_ids => [user.id])
      assert usergroup.valid?, "Can't create usergroup with valid user #{user}"
      assert_equal 1, usergroup.users.length
      assert_equal login, usergroup.users.first.name
    end
  end

  test 'should create with valid usergroup' do
    valid_name_list.each do |name|
      sub_usergroup = FactoryBot.create(:usergroup, :name => name)
      usergroup = FactoryBot.build(:usergroup, :usergroup_ids => [sub_usergroup.id])
      assert usergroup.valid?, "Can't create usergroup with valid usergroup #{sub_usergroup}"
      assert_equal 1, usergroup.usergroups.length
      assert_equal name, usergroup.usergroups.first.name
    end
  end

  context 'Jail' do
    test 'should allow methods' do
      allowed = [:ssh_keys, :ssh_authorized_keys]

      allowed.each do |m|
        assert Usergroup::Jail.allowed?(m), "Method #{m} is not available in Usergroup::Jail while should be allowed."
      end
    end
  end

  def populate_usergroups
    (1..6).each do |number|
      instance_variable_set("@ug#{number}", FactoryBot.create(:usergroup, :name => "ug#{number}"))
      instance_variable_set("@u#{number}", FactoryBot.create(:user, :mail => "u#{number}@someware.com",
                                                              :login => "u#{number}"))
    end

    @ug1.users      = [@u1, @u2]
    @ug2.users      = [@u2, @u3]
    @ug3.users      = [@u3, @u4]
    @ug3.usergroups = [@ug1]
    @ug4.usergroups = [@ug1, @ug2]
    @ug5.usergroups = [@ug1, @ug3, @ug4]
    @ug5.users      = [@u5]
  end

  test "hosts should be retrieved from recursive/complex usergroup definitions" do
    populate_usergroups
    disable_orchestration

    @h1 = FactoryBot.create(:host, :owner => @u1)
    @h2 = FactoryBot.create(:host, :owner => @ug2)
    @h3 = FactoryBot.create(:host, :owner => @u3)
    @h4 = FactoryBot.create(:host, :owner => @ug5)
    @h5 = FactoryBot.create(:host, :owner => @u2)
    @h6 = FactoryBot.create(:host, :owner => @ug3)

    assert_equal [@h1], @u1.hosts
    assert_equal [@h2, @h5].sort, @u2.hosts.sort
    assert_equal [@h2, @h3, @h6].sort, @u3.hosts.sort
    assert_equal [@h6], @u4.hosts
    assert_equal [@h2, @h4, @h6].sort, @u5.hosts.sort
    assert_equal [], @u6.hosts
  end

  test "addresses should be retrieved from recursive/complex usergroup definitions" do
    populate_usergroups

    assert_equal @ug1.recipients.sort, %w{u1@someware.com u2@someware.com}
    assert_equal @ug2.recipients.sort, %w{u2@someware.com u3@someware.com}
    assert_equal @ug3.recipients.sort, %w{u1@someware.com u2@someware.com u3@someware.com u4@someware.com}
    assert_equal @ug4.recipients.sort, %w{u1@someware.com u2@someware.com u3@someware.com}
    assert_equal @ug5.recipients.sort, %w{u1@someware.com u2@someware.com u3@someware.com u4@someware.com u5@someware.com}
  end

  test "cannot be destroyed when in use by a host" do
    disable_orchestration
    @ug1 = Usergroup.where(:name => "ug1").first_or_create
    @h1  = FactoryBot.create(:host)
    @h1.update :owner => @ug1
    @ug1.destroy
    assert_equal @ug1.errors.full_messages[0], "ug1 is used by #{@h1}"
  end

  test "can be destroyed when in use by another usergroup, it removes association automatically" do
    @ug1 = Usergroup.where(:name => "ug1").first_or_create
    @ug2 = Usergroup.where(:name => "ug2").first_or_create
    @ug1.usergroups = [@ug2]
    assert @ug1.destroy
    assert @ug2.reload
    assert_empty UsergroupMember.where(:member_id => @ug2.id)
  end

  test "removes all cached_user_roles when roles are disassociated" do
    user         = FactoryBot.create(:user)
    record       = FactoryBot.create(:usergroup)
    record.users = [user]
    one          = FactoryBot.create(:role)
    two          = FactoryBot.create(:role)

    record.roles = [one, two]
    assert_equal 3, user.reload.cached_user_roles.size

    assert record.update(:role_ids => [two.id])
    assert_equal 2, user.reload.cached_user_roles.size

    record.role_ids = []
    assert_equal 1, user.reload.cached_user_roles.size

    assert record.update_attribute(:role_ids, [one.id])
    assert_equal 2, user.reload.cached_user_roles.size

    record.roles << two
    assert_equal 3, user.reload.cached_user_roles.size
  end

  test "can remove the admin flag from the group when another admin exists" do
    usergroup = FactoryBot.create(:usergroup, :admin => true)
    admin1 = FactoryBot.create(:user)
    admin2 = FactoryBot.create(:user, :admin => true)
    usergroup.users = [admin1]

    User.unscoped.except_hidden.only_admin.where('login NOT IN (?)', [admin1.login, admin2.login]).destroy_all
    usergroup.admin = false
    assert_valid usergroup
  end

  test "cannot remove the admin flag from the group providing the last admin account(s)" do
    usergroup = FactoryBot.create(:usergroup, :admin => true)
    admin = FactoryBot.create(:user)
    usergroup.users = [admin]

    User.unscoped.except_hidden.only_admin.where('login <> ?', admin.login).destroy_all
    usergroup.admin = false
    refute_valid usergroup, :admin, /last admin account/
  end

  test "cannot destroy the group providing the last admin accounts" do
    usergroup = FactoryBot.create(:usergroup, :admin => true)
    admin = FactoryBot.create(:user)
    usergroup.users = [admin]

    User.unscoped.except_hidden.only_admin.where('login <> ?', admin.login).destroy_all
    refute_with_errors usergroup.destroy, usergroup, :base, /last admin user group/
  end

  test "receipients_for provides subscribers of notification recipients" do
    users = [FactoryBot.create(:user, :with_mail_notification), FactoryBot.create(:user)]
    notification = users[0].mail_notifications.first.name
    usergroup = FactoryBot.create(:usergroup)
    usergroup.users << users
    recipients = usergroup.recipients_for(notification)
    assert_equal recipients, [users[0]]
  end

  # TODO test who can modify usergroup roles and who can assign users!!! possible privileges escalation

  context 'external usergroups' do
    setup do
      @usergroup = FactoryBot.create(:usergroup)
      auth_source_ldap = FactoryBot.create(:auth_source_ldap)
      @external = @usergroup.external_usergroups.new(:auth_source_id => auth_source_ldap.id,
                                                     :name           => 'aname')
      LdapFluff.any_instance.stubs(:ldap).returns(Net::LDAP.new)
      users(:one).update_column(:auth_source_id, auth_source_ldap.id)
    end

    test "can be associated with external_usergroups" do
      LdapFluff.any_instance.stubs(:valid_group?).returns(true)

      assert @external.save
      assert @usergroup.external_usergroups.include? @external
    end

    test "won't save if usergroup is not in LDAP" do
      LdapFluff.any_instance.stubs(:valid_group?).returns(false)

      refute @external.save
      assert_equal @external.errors.first, [:name, 'is not found in the authentication source']
    end

    test "delete user if not in LDAP directory" do
      LdapFluff.any_instance.stubs(:valid_group?).with('aname').returns(true)
      @usergroup.user_ids = [users(:one).id]
      @usergroup.save

      AuthSourceLdap.any_instance.expects(:users_in_group).with('aname').returns([])
      @usergroup.external_usergroups.find { |eu| eu.name == 'aname' }.refresh

      refute_includes @usergroup.users, users(:one)
    end

    test "add user if in LDAP directory" do
      LdapFluff.any_instance.stubs(:valid_group?).with('aname').returns(true)
      @usergroup.save

      AuthSourceLdap.any_instance.expects(:users_in_group).with('aname').returns([users(:one).login])
      @usergroup.external_usergroups.find { |eu| eu.name == 'aname' }.refresh
      assert_includes @usergroup.users, users(:one)
    end

    test "keep user if in LDAP directory" do
      LdapFluff.any_instance.stubs(:valid_group?).with('aname').returns(true)
      @usergroup.user_ids = [users(:one).id]
      @usergroup.save

      AuthSourceLdap.any_instance.expects(:users_in_group).with('aname').returns([users(:one).login])
      @usergroup.external_usergroups.find { |eu| eu.name == 'aname' }.refresh
      assert_includes @usergroup.reload.users, users(:one)
    end

    test 'internal auth source users remain after refresh' do
      external_user = FactoryBot.create(
        :user,
        :auth_source => @external.auth_source,
        :login => 'external_user'
      )
      internal_user = FactoryBot.create(:user)
      LdapFluff.any_instance.stubs(:valid_group?).with('aname').returns(true)
      @usergroup.user_ids = [internal_user.id, external_user.id]
      @usergroup.save

      AuthSourceLdap.any_instance.expects(:users_in_group).with('aname').
        returns(['external_user'])
      @usergroup.external_usergroups.detect { |eu| eu.name == 'aname' }.refresh
      assert_includes @usergroup.users, internal_user
      assert_includes @usergroup.users, external_user
    end
  end

  test 'can search usergroup by role id' do
    # Setup role and assign to user
    role = Role.where(:name => "foobar").first_or_create
    usergroup = FactoryBot.create(:usergroup)
    usergroup.role_ids = [role.id]

    groups = Usergroup.search_for("role_id = #{role.id}")
    assert (groups.include? usergroup)
  end

  test 'can search usergroup by role' do
    # Setup role and assign to user
    role = Role.where(:name => "foobar").first_or_create
    usergroup = FactoryBot.create(:usergroup)
    usergroup.role_ids = [role.id]

    groups = Usergroup.search_for("role = #{role.name}")
    assert (groups.include? usergroup)
  end

  context 'audit usergroup' do
    context 'child usergroups' do
      let (:usergroup) { FactoryBot.create(:usergroup, :with_auditing) }
      let (:child_usergroup) { FactoryBot.create(:usergroup) }

      before do
        usergroup.usergroup_ids = [child_usergroup.id]
        usergroup.save
      end

      test 'should audit when a child-usergroup is assigned to a parent-usergroup' do
        recent_audit = usergroup.audits.last
        audited_changes = recent_audit.audited_changes['usergroup_ids']
        assert audited_changes, 'No audits found for usergroups'
        assert_empty audited_changes.first
        assert_equal [child_usergroup.id], audited_changes.last
      end

      test 'should audit when a child-usergroup is removed/de-assigned from a parent-usergroup' do
        usergroup.usergroup_ids = []
        usergroup.save
        recent_audit = usergroup.audits.last
        audited_changes = recent_audit.audited_changes['usergroup_ids']
        assert audited_changes, 'No audits found for usergroups'
        assert_equal [child_usergroup.id], audited_changes.first
        assert_empty audited_changes.last
      end
    end

    context 'roles' do
      let (:usergroup) { FactoryBot.create(:usergroup, :with_auditing) }
      let (:role) { FactoryBot.create(:role) }

      before do
        usergroup.role_ids = [role.id]
        usergroup.save
      end

      test 'should audit when a role is assigned to a usergroup' do
        recent_audit = usergroup.audits.last
        audited_changes = recent_audit.audited_changes['role_ids']
        assert audited_changes, 'No audits found for user-roles'
        assert_empty audited_changes.first
        assert_equal [role.id], audited_changes.last
      end

      test 'should audit when a role is removed/de-assigned from a usergroup' do
        usergroup.role_ids = []
        usergroup.save
        recent_audit = usergroup.audits.last
        audited_changes = recent_audit.audited_changes['role_ids']
        assert audited_changes, 'No audits found for usergroup-roles'
        assert_equal [role.id], audited_changes.first
        assert_empty audited_changes.last
      end
    end

    context 'users' do
      let (:usergroup) { FactoryBot.create(:usergroup, :with_auditing) }
      let (:user) { users(:one) }

      before do
        usergroup.user_ids = [user.id]
        usergroup.save
      end

      test 'should audit when a user is assigned to a usergroup' do
        recent_audit = usergroup.audits.last
        audited_changes = recent_audit.audited_changes['user_ids']
        assert audited_changes, 'No audits found for users'
        assert_empty audited_changes.first
        assert_equal [user.id], audited_changes.last
      end

      test 'should audit when a user is removed/de-assigned from a usergroup' do
        usergroup.user_ids = []
        usergroup.save
        recent_audit = usergroup.audits.last
        audited_changes = recent_audit.audited_changes['user_ids']
        assert audited_changes, 'No audits found for users'
        assert_equal [user.id], audited_changes.first
        assert_empty audited_changes.last
      end
    end
  end

  test 'should list all usergroups but current' do
    5.times { FactoryBot.create(:usergroup) }
    group = Usergroup.all
    last = Usergroup.last
    res = Usergroup.except_current last
    assert_equal(group.count - 1, res.count)
    refute res.include?(last)
  end

  it 'provides data for export' do
    user = FactoryBot.create(:user, :with_usergroup, :with_ssh_key)
    usergroup = user.usergroups.first

    expected = {
      user.login => {
        'firstname' => user.firstname,
        'lastname' => user.lastname,
        'mail' => user.mail,
        'description' => user.description,
        'fullname' => user.fullname,
        'name' => user.name,
        'ssh_authorized_keys' => user.ssh_keys.map(&:to_export_hash),
      },
    }

    assert_equal expected, usergroup.to_export
  end
end
