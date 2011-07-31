require 'test_helper'

class UsergroupTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login("admin")
  end
  test "usergroups should be creatable" do
    assert Usergroup.create(:name => "name").valid?
  end

  test "name should be unique" do
    one = Usergroup.create :name => "one"
    two = Usergroup.create :name => "one"

    assert !two.valid?
  end

  test "name is unique across user as well as usergroup" do
    user = User.create :auth_source => auth_sources(:one), :login => "user", :mail  => "user@someware.com"
    usergroup  = Usergroup.create :name => "user"

    assert !usergroup.valid?
  end

  def populate_usergroups
    @u1 = User.find_or_create_by_login :login => "u1", :mail => "u1@someware.com", :firstname => "u1", :auth_source => auth_sources(:one)
    @u2 = User.find_or_create_by_login :login => "u2", :mail => "u2@someware.com", :firstname => "u2", :auth_source => auth_sources(:one)
    @u3 = User.find_or_create_by_login :login => "u3", :mail => "u3@someware.com", :firstname => "u3", :auth_source => auth_sources(:one)
    @u4 = User.find_or_create_by_login :login => "u4", :mail => "u4@someware.com", :firstname => "u4", :auth_source => auth_sources(:one)
    @u5 = User.find_or_create_by_login :login => "u5", :mail => "u5@someware.com", :firstname => "u5", :auth_source => auth_sources(:one)
    @u6 = User.find_or_create_by_login :login => "u6", :mail => "u6@someware.com", :firstname => "u6", :auth_source => auth_sources(:one)

    @ug1 = Usergroup.find_or_create_by_name :name => "ug1"
    @ug2 = Usergroup.find_or_create_by_name :name => "ug2"
    @ug3 = Usergroup.find_or_create_by_name :name => "ug3"
    @ug4 = Usergroup.find_or_create_by_name :name => "ug4"
    @ug5 = Usergroup.find_or_create_by_name :name => "ug5"
    @ug6 = Usergroup.find_or_create_by_name :name => "ug6"

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
    domain = domains(:mydomain)

    Host.with_options :architecture => architectures(:x86_64), :environment => environments(:production), :operatingsystem => operatingsystems(:redhat), :ptable => ptables(:one), :subnet => subnets(:one) do |object|
      @h1 = object.find_or_create_by_name :name => "h1.someware.com", :ip => "2.3.4.10", :mac => "223344556601", :owner => @u1, :domain => domain
      @h2 = object.find_or_create_by_name :name => "h2.someware.com", :ip => "2.3.4.11", :mac => "223344556602", :owner => @ug2, :domain => domain
      @h3 = object.find_or_create_by_name :name => "h3.someware.com", :ip => "2.3.4.12", :mac => "223344556603", :owner => @u3, :domain => domain
      @h4 = object.find_or_create_by_name :name => "h4.someware.com", :ip => "2.3.4.13", :mac => "223344556604", :owner => @ug5, :domain => domain
      @h5 = object.find_or_create_by_name :name => "h5.someware.com", :ip => "2.3.4.14", :mac => "223344556605", :owner => @u2, :domain => domain
      @h6 = object.find_or_create_by_name :name => "h6.someware.com", :ip => "2.3.4.15", :mac => "223344556606", :owner => @ug3, :domain => domain
    end
    assert @u1.hosts.sort == [@h1]
    assert @u2.hosts.sort == [@h2, @h5]
    assert @u3.hosts.sort == [@h2, @h3, @h6]
    assert @u4.hosts.sort == [@h6]
    assert @u5.hosts.sort == [@h2, @h4, @h6]
    assert @u6.hosts.sort == []
  end

  test "addresses should be retrieved from recursive/complex usergroup definitions" do
    populate_usergroups

    assert @ug1.recipients.sort == %w{u1@someware.com u2@someware.com}
    assert @ug2.recipients.sort == %w{u2@someware.com u3@someware.com}
    assert @ug3.recipients.sort == %w{u1@someware.com u2@someware.com u3@someware.com u4@someware.com}
    assert @ug4.recipients.sort == %w{u1@someware.com u2@someware.com u3@someware.com}
    assert @ug5.recipients.sort == %w{u1@someware.com u2@someware.com u3@someware.com u4@someware.com u5@someware.com}
  end

  test "cannot be destroyed when in use by a host" do
    @ug1 = Usergroup.find_or_create_by_name :name => "ug1"
    @h1  = hosts(:one)
    @h1.update_attributes :owner => @ug1
    @ug1.destroy
    assert @ug1.errors.full_messages[0] == "ug1 is used by #{@h1}"
  end

  test "cannot be destroyed when in use by another usergroup" do
    @ug1 = Usergroup.find_or_create_by_name :name => "ug1"
    @ug2 = Usergroup.find_or_create_by_name :name => "ug2"
    @ug1.usergroups = [@ug2]
    @ug1.destroy
    assert @ug1.errors.full_messages[0] == "ug1 is used by ug2"
  end

  test "removes user join model records" do
    ug1 = Usergroup.find_or_create_by_name :name => "ug1"
    u1  = User.find_or_create_by_login :login => "u1", :mail => "u1@someware.com", :auth_source => auth_sources(:one)
    ug1.users = [u1]
    assert_difference('UsergroupMember.count', -1) do
      ug1.destroy
    end
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_usergroups"
      role.permissions = ["#{operation}_usergroups".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  Usergroup.create :name => "dummy"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Usergroup.create :name => "dummy"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  Usergroup.first
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Usergroup.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Usergroup.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Usergroup.first
    record.name = "renamed"
    assert !record.save
    assert record.valid?
  end

end
