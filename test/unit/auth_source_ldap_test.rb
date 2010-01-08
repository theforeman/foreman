require 'test_helper'

class AuthSourceLdapTest < ActiveSupport::TestCase
  def setup
    @auth_source_ldap = AuthSourceLdap.new
    @attributes = { :name= => "value",
                    :host= => "value",
                    :attr_login= => "value",
                    :port= => 389  }
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
    assert !@auth_source_ldap.save

    set(:attr_login=)
    assert @auth_source_ldap.save
  end

  test "should exists a port" do
    missing(:port=)
    assert !@auth_source_ldap.save

    set(:port=)
    assert @auth_source_ldap.save
  end

  test "after initiliaze if port == 0 should automatically change to 389" do
    other_auth_source_ldap = AuthSourceLdap.new(:port => 0)
    assert_equal 389, other_auth_source_ldap.port
  end

  test "the name should not exceed the 60 characters" do
    missing(:name=)
    @auth_source_ldap.name = "this_is_10this_is_20this_is_30this_is_40this_is_50this_is_60_and_something_else"
    assert !@auth_source_ldap.save
  end

  test "the host should not exceed the 60 characters" do
    missing(:host=)
    @auth_source_ldap.host = "this_is_10this_is_20this_is_30this_is_40this_is_50this_is_60_and_something_else"
    assert !@auth_source_ldap.save
  end

  test "the account_password should not exceed the 60 characters" do
    set_all
    @auth_source_ldap.account_password = "this_is_10this_is_20this_is_30this_is_40this_is_50this_is_60_and_something_else"
    assert !@auth_source_ldap.save
  end

  test "the account should not exceed the 255 characters" do
    set_all
    @auth_source_ldap.account = "this is010this is020this is030this is040this is050this is060this is070this is080this is090this is100this is110this is120this is130this is140this is150this is160this is170this is180this is190this is200this is210this is220this is230this is240this is250 and something else"
    assert !@auth_source_ldap.save
  end

  test "the base_dn should not exceed the 255 characters" do
    set_all
    @auth_source_ldap.base_dn = "this is010this is020this is030this is040this is050this is060this is070this is080this is090this is100this is110this is120this is130this is140this is150this is160this is170this is180this is190this is200this is210this is220this is230this is240this is250 and something else"
    assert !@auth_source_ldap.save
  end

  test "the attr_login should not exceed the 30 characters" do
    missing(:attr_login=)
    @auth_source_ldap.attr_login = "this_is_10this_is_20this_is_30_and_something_else"
    assert !@auth_source_ldap.save
  end

  test "the attr_firstname should not exceed the 30 characters" do
    set_all
    @auth_source_ldap.attr_firstname = "this_is_10this_is_20this_is_30_and_something_else"
    assert !@auth_source_ldap.save
  end

  test "the attr_lastname should not exceed the 30 characters" do
    set_all
    @auth_source_ldap.attr_lastname = "this_is_10this_is_20this_is_30_and_something_else"
    assert !@auth_source_ldap.save
  end

  test "the attr_mail should not exceed the 30 characters" do
    set_all
    @auth_source_ldap.attr_mail = "this_is_10this_is_20this_is_30_and_something_else"
    assert !@auth_source_ldap.save
  end

  test "port should be a integer" do
    missing(:port=)
    @auth_source_ldap.port = "crap"
    assert !@auth_source_ldap.save

    @auth_source_ldap.port = 123
    assert @auth_source_ldap.save
  end

  test "return nil if login is blank or password is blank" do
    assert_equal nil, @auth_source_ldap.authenticate("", "")
  end

  def missing(attr)
    @attributes.each { |k, v| @auth_source_ldap.send k, v unless k == attr }
  end

  def set(attr)
    @auth_source_ldap.send attr, @attributes[attr]
  end

  def set_all
    @attributes.each { |k, v| @auth_source_ldap.send k, v }
  end
end

