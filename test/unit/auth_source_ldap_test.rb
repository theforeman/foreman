require 'test_helper'

class AuthSourceLdapTest < ActiveSupport::TestCase
  def setup
    @auth_source_ldap = AuthSourceLdap.new
    @attributes = { :name= => "value",
                    :host= => "value",
                    :attr_login= => "value",
                    :attr_mail= => "some@where.com",
                    :attr_firstname= => "ohad",
                    :attr_lastname=  => "daho",
                    :port= => 389 }
    User.current = users(:admin)
  end

  test "should exists a name" do
    missing(:name=)
    assert !@auth_source_ldap.save

    set(:name=)
    assert @auth_source_ldap.save
  end

  test "should exists a host" do
    missing(:host=)
    assert !@auth_source_ldap.save

    set(:host=)
    assert @auth_source_ldap.save
  end

  test "should exists a attr_login" do
    missing(:attr_login=)
    @auth_source_ldap.onthefly_register = true
    assert !@auth_source_ldap.save

    set(:attr_login=)
    set(:attr_firstname=)
    set(:attr_lastname=)
    set(:attr_mail=)
    @auth_source_ldap.onthefly_register = true
    assert @auth_source_ldap.save
  end

  test "after initialize if port == 0 should automatically change to 389" do
    other_auth_source_ldap = AuthSourceLdap.new
    assert_equal 389, other_auth_source_ldap.port
  end

  test "the name should not exceed the 60 characters" do
    missing(:name=)
    assigns_a_string_of_length_greater_than(60, :name=)
    assert !@auth_source_ldap.save
  end

  test "the host should not exceed the 60 characters" do
    missing(:host=)
    assigns_a_string_of_length_greater_than(60, :host=)
    assert !@auth_source_ldap.save
  end

  test "the account_password should not exceed the 60 characters" do
    set_all_required_attributes
    assigns_a_string_of_length_greater_than(60, :account_password=)
    assert !@auth_source_ldap.save
  end

  test "the account should not exceed the 255 characters" do
    set_all_required_attributes
    assigns_a_string_of_length_greater_than(255, :account=)
    assert !@auth_source_ldap.save
  end

  test "the base_dn should not exceed the 255 characters" do
    set_all_required_attributes
    assigns_a_string_of_length_greater_than(255, :base_dn=)
    assert !@auth_source_ldap.save
  end

  test "the attr_login should not exceed the 30 characters" do
    missing(:attr_login=)
    assigns_a_string_of_length_greater_than(30, :attr_login=)
    assert !@auth_source_ldap.save
  end

  test "the attr_firstname should not exceed the 30 characters" do
    set_all_required_attributes
    assigns_a_string_of_length_greater_than(30, :attr_firstname=)
    assert !@auth_source_ldap.save
  end

  test "the attr_lastname should not exceed the 30 characters" do
    set_all_required_attributes
    assigns_a_string_of_length_greater_than(30, :attr_lastname=)
    assert !@auth_source_ldap.save
  end

  test "the attr_mail should not exceed the 30 characters" do
    set_all_required_attributes
    assigns_a_string_of_length_greater_than(30, :attr_mail=)
    assert !@auth_source_ldap.save
  end

  test "port should be a integer" do
    missing(:port=)
    @auth_source_ldap.port = "crap"
    assert !@auth_source_ldap.save

    @auth_source_ldap.port = 123
    assert @auth_source_ldap.save
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
    assert_equal nil, @auth_source_ldap.authenticate("", "")
  end

  test "when auth_method_name is applied should return 'LDAP'" do
    set_all_required_attributes
    @auth_source_ldap.save

    assert_equal 'LDAP', @auth_source_ldap.auth_method_name
  end

  def missing(attr)
    @attributes.each { |k, v| @auth_source_ldap.send k, v unless k == attr }
  end

  def set(attr)
    @auth_source_ldap.send attr, @attributes[attr]
  end

  def set_all_required_attributes
    @attributes.each { |k, v| @auth_source_ldap.send k, v }
  end

  def assigns_a_string_of_length_greater_than(length, method)
    @auth_source_ldap.send method, "this is010this is020this is030this is040this is050this is060this is070this is080this is090this is100this is110this is120this is130this is140this is150this is160this is170this is180this is190this is200this is210this is220this is230this is240this is250 and something else"
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_authenticators"
      role.permissions = ["#{operation}_authenticators".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  AuthSourceLdap.create :name => "dummy", :host => hosts(:one).name, :port => "1", :attr_login => "login"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  AuthSourceLdap.create :name => "dummy", :host => hosts(:one).name, :port => "1", :attr_login => "login"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  AuthSourceLdap.first
    as_admin do
      record.users.delete_all
    end
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  AuthSourceLdap.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  AuthSourceLdap.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  AuthSourceLdap.first
    record.name = "renamed"
    assert !record.save
  end
end
