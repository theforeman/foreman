require 'test_helper'

class AuthSourceLdapTest < ActiveSupport::TestCase
  def setup
    @auth_source_ldap = FactoryGirl.create(:auth_source_ldap)
    User.current = users(:admin)
  end

  test "should exists a name" do
    missing(:name)
    refute @auth_source_ldap.save

    set(:name)
    assert @auth_source_ldap.save
  end

  test "should exists a host" do
    missing(:host)
    refute @auth_source_ldap.save

    set(:host)
    assert @auth_source_ldap.save
  end

  test "should exists a attr_login" do
    missing(:attr_login)
    @auth_source_ldap.onthefly_register = true
    refute @auth_source_ldap.save

    set(:attr_login)
    set(:attr_firstname)
    set(:attr_lastname)
    set(:attr_mail)
    @auth_source_ldap.onthefly_register = true
    assert @auth_source_ldap.save
  end

  test "after initialize if port == 0 should automatically change to 389" do
    other_auth_source_ldap = AuthSourceLdap.new
    assert_equal 389, other_auth_source_ldap.port
  end

  test "the name should not exceed the 60 characters" do
    missing(:name)
    assigns_a_string_of_length_greater_than(60, :name=)
    refute @auth_source_ldap.save
  end

  test "the host should not exceed the 60 characters" do
    missing(:host)
    assigns_a_string_of_length_greater_than(60, :host=)
    refute @auth_source_ldap.save
  end

  test "the account_password should not exceed the 60 characters" do
    assigns_a_string_of_length_greater_than(60, :account_password=)
    refute @auth_source_ldap.save
  end

  test "the account should not exceed the 255 characters" do
    assigns_a_string_of_length_greater_than(255, :account=)
    refute @auth_source_ldap.save
  end

  test "the base_dn should not exceed the 255 characters" do
    assigns_a_string_of_length_greater_than(255, :base_dn=)
    refute @auth_source_ldap.save
  end

  test "the ldap_filter should not exceed the 255 characters" do
    assigns_a_string_of_length_greater_than(255, :ldap_filter=)
    refute @auth_source_ldap.save
  end

  test "the attr_login should not exceed the 30 characters" do
    missing(:attr_login)
    assigns_a_string_of_length_greater_than(30, :attr_login=)
    refute @auth_source_ldap.save
  end

  test "the attr_firstname should not exceed the 30 characters" do
    assigns_a_string_of_length_greater_than(30, :attr_firstname=)
    refute @auth_source_ldap.save
  end

  test "the attr_lastname should not exceed the 30 characters" do
    assigns_a_string_of_length_greater_than(30, :attr_lastname=)
    refute @auth_source_ldap.save
  end

  test "the attr_mail should not exceed the 30 characters" do
    assigns_a_string_of_length_greater_than(30, :attr_mail=)
    refute @auth_source_ldap.save
  end

  test "port should be a integer" do
    missing(:port)
    @auth_source_ldap.port = "crap"
    refute @auth_source_ldap.save

    @auth_source_ldap.port = 123
    assert @auth_source_ldap.save
  end

  test "invalid ldap_filter fails validation" do
    @auth_source_ldap.ldap_filter = "("
    refute @auth_source_ldap.valid?
  end

  test "valid ldap_filter passes validation" do
    missing(:ldap_filter)
    assert @auth_source_ldap.valid?

    @auth_source_ldap.ldap_filter = ""
    assert @auth_source_ldap.valid?

    @auth_source_ldap.ldap_filter = "   "
    assert @auth_source_ldap.valid?

    @auth_source_ldap.ldap_filter = "key=value"
    assert @auth_source_ldap.valid?
  end

  test "should strip the ldap attributes before validate" do
    @auth_source_ldap.attr_login = "following spaces    "
    @auth_source_ldap.attr_firstname = "following spaces    "
    @auth_source_ldap.attr_lastname = "following spaces    "
    @auth_source_ldap.attr_mail = "following spaces    "
    @auth_source_ldap.save

    assert_equal "following spaces", @auth_source_ldap.attr_login
    assert_equal "following spaces", @auth_source_ldap.attr_firstname
    assert_equal "following spaces", @auth_source_ldap.attr_lastname
    assert_equal "following spaces", @auth_source_ldap.attr_mail
  end

  test "return nil if login is blank or password is blank" do
    assert_nil @auth_source_ldap.authenticate("", "")
  end

  test "when auth_method_name is applied should return 'LDAP'" do
    @auth_source_ldap.save

    assert_equal 'LDAP', @auth_source_ldap.auth_method_name
  end

  test "ldap user should be able to login" do
    # stubs out all the actual ldap connectivity, but tests the authenticate
    # method of auth_source_ldap
    setup_ldap_stubs
    LdapFluff.any_instance.stubs(:authenticate?).returns(true)
    LdapFluff.any_instance.stubs(:group_list).returns([])
    assert_not_nil AuthSourceLdap.authenticate("test123", "changeme")
  end

  test 'update_usergroups returns if entry does not belong to any group' do
    setup_ldap_stubs
    ExternalUsergroup.any_instance.expects(:refresh).never
    LdapFluff.any_instance.expects(:group_list).with('test').returns([])
    @auth_source_ldap.send(:update_usergroups, 'test')
  end

  context 'refresh ldap' do
    setup do
      setup_ldap_stubs
      LdapFluff.any_instance.expects(:group_list).with('test').returns(['ipausers'])
    end

    test 'update_usergroups calls refresh_ldap if entry belongs to some group' do
      ExternalUsergroup.expects(:find_by_name).with('ipausers').returns(ExternalUsergroup.new)
      @auth_source_ldap.send(:update_usergroups, 'test')
    end

    test 'update_usergroups refreshes on all external user groups, in LDAP and in Foreman auth source' do
      @auth_source_ldap.stubs(:valid_group?).returns(true)
      external = FactoryGirl.create(:external_usergroup, :auth_source => @auth_source_ldap)
      User.any_instance.expects(:external_usergroups).returns([external])
      @auth_source_ldap.send(:update_usergroups, 'test')
    end
  end

  test '#to_config with dedicated service account returns hash' do
    conf = FactoryGirl.build(:auth_source_ldap, :service_account).to_config
    assert_kind_of Hash, conf
    refute conf[:anon_queries]
  end

  test '#to_config with $login service account and no username fails' do
    ldap = FactoryGirl.build(:auth_source_ldap, :account => 'DOMAIN/$login')
    assert_raise(Foreman::Exception) { ldap.to_config }
  end

  test '#to_config with $login service account and username returns hash with service user' do
    conf = FactoryGirl.build(:auth_source_ldap, :account => 'DOMAIN/$login').to_config('user', 'pass')
    assert_kind_of Hash, conf
    refute conf[:anon_queries]
    assert_equal 'DOMAIN/user', conf[:service_user]
  end

  test '#to_config with no service account returns hash with anonymous queries' do
    conf = FactoryGirl.build(:auth_source_ldap).to_config('user', 'pass')
    assert_kind_of Hash, conf
    assert conf[:anon_queries]
  end

  test '#ldap_con does not cache connections with user auth' do
    ldap = FactoryGirl.build(:auth_source_ldap, :account => 'DOMAIN/$login')
    refute_equal ldap.ldap_con('user', 'pass'), ldap.ldap_con('user', 'pass')
  end

  private

  def setup_ldap_stubs
    # stub out all the LDAP connectivity
    entry = Net::LDAP::Entry.new
    {:givenname=>["test"], :dn=>["uid=test123,cn=users,cn=accounts,dc=example,dc=com"], :mail=>["test123@example.com"], :sn=>["test"]}.each do |k, v|
      entry[k] = v
    end
    LdapFluff.any_instance.stubs(:valid_user?).returns(true)
    LdapFluff.any_instance.stubs(:find_user).returns([entry])
  end

  def missing(attr)
    @auth_source_ldap.send("#{attr}=", nil)
  end

  def set(attr)
    @auth_source_ldap.send("#{attr}=", FactoryGirl.attributes_for(:auth_source_ldap)[attr])
  end

  def assigns_a_string_of_length_greater_than(length, method)
    @auth_source_ldap.send method, "this is010this is020this is030this is040this is050this is060this is070this is080this is090this is100this is110this is120this is130this is140this is150this is160this is170this is180this is190this is200this is210this is220this is230this is240this is250 and something else"
  end

end
