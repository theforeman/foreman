require 'test_helper'

class HostParameterTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end
  test "should have a reference_id" do
    host_parameter = HostParameter.new
    host_parameter.name = "valid"
    host_parameter.value = "valid"
    assert !host_parameter.save

    host = Host.first
    host_parameter.reference_id = host.id
    assert host_parameter.save
  end

  test "duplicate names cannot exist for a host" do
    as_admin do
      @host = Host.create! :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
                          :domain => domains(:mydomain) , :operatingsystem => Operatingsystem.first, :hostgroup => hostgroups(:common),
                          :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"

      @parameter1 = HostParameter.create :name => "some parameter", :value => "value", :reference_id => @host.id
      @parameter2 = HostParameter.create :name => "some parameter", :value => "value", :reference_id => @host.id
    end
    assert !@parameter2.valid?
    assert  @parameter2.errors.full_messages[0] == "Name has already been taken"
  end

  test "duplicate names can exist for different hosts" do
    as_admin do
      @host1 = Host.create! :name => "myfullhost", :mac => "aabbecddeeff", :ip => "123.05.02.03",
                            :domain => domains(:mydomain) , :operatingsystem => Operatingsystem.first, :hostgroup => hostgroups(:common),
                            :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"
      @host2 = Host.create! :name => "anotherfullhost", :mac => "aabbecddee00", :ip => "123.05.02.04",
                            :domain => domains(:mydomain) , :operatingsystem => Operatingsystem.first, :hostgroup => hostgroups(:common),
                            :architecture => Architecture.first, :environment => Environment.first, :disk => "empty partition"
      @parameter1 = HostParameter.create! :name => "some parameter", :value => "value", :reference_id => @host1.id
      @parameter2 = HostParameter.create! :name => "some parameter", :value => "value", :reference_id => @host2.id
    end
    assert @parameter2.valid?
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_hosts"
      role.permissions = ["#{operation}_hosts".to_sym]
      @one.roles      = [role]
      @one.domains    = []
      @one.hostgroups = []
      @one.user_facts = []
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create when permitted" do
    setup_user "create"
    as_admin do
      @one.domains = [domains(:mydomain)]
      @one.save!
    end
    record =  HostParameter.create :name => "dummy", :value => "value", :reference_id => hosts(:one).id
    assert record.valid?
    assert !record.new_record?
  end

  test "user with create permissions should not be able to create when not permitted" do
    setup_user "create"
    as_admin do
      @one.hostgroups = [hostgroups(:common)]
      @one.save!
      hosts(:one).update_attribute :hostgroup, hostgroups(:unusual)
    end
    record =  HostParameter.create :name => "dummy", :value => "value", :reference_id => hosts(:one).id
    assert record.valid?
    assert record.new_record?
  end

  test "user with create permissions should be able to create when unconstrained" do
    setup_user "create"
    as_admin do
      @one.domains = []
    end
    record =  HostParameter.create :name => "dummy", :value => "value", :reference_id => hosts(:one).id
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  HostParameter.create :name => "dummy", :value => "value", :reference_id => hosts(:one).id
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  HostParameter.first
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  HostParameter.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  HostParameter.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  HostParameter.first
    record.name = "renamed"
    assert !record.save
  end
end
