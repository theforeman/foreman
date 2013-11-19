require 'test_helper'

class SystemParameterTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end
  test "should have a reference_id" do
    system_parameter = SystemParameter.new
    system_parameter.name = "valid"
    system_parameter.value = "valid"
    assert !system_parameter.save

    system = System.first
    system_parameter.reference_id = system.id
    assert system_parameter.save
  end

  test "duplicate names cannot exist for a system" do
    @system = systems(:one)
    as_admin do
      @parameter1 = SystemParameter.create :name => "some_parameter", :value => "value", :reference_id => @system.id
      @parameter2 = SystemParameter.create :name => "some_parameter", :value => "value", :reference_id => @system.id
    end
    assert !@parameter2.valid?
    assert  @parameter2.errors.full_messages[0] == "Name has already been taken"
  end

  test "duplicate names can exist for different systems" do
    @system1 = systems(:one)
    @system2 = systems(:two)
    as_admin do
      @parameter1 = SystemParameter.create! :name => "some_parameter", :value => "value", :reference_id => @system1.id
      @parameter2 = SystemParameter.create! :name => "some_parameter", :value => "value", :reference_id => @system2.id
    end
    assert @parameter2.valid?
  end

  def setup_user operation, type = "params"
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_#{type}"
      role.permissions = ["#{operation}_#{type}".to_sym]
      @one.roles      = [role]
      @one.domains.destroy_all
      @one.system_groups.destroy_all
      @one.user_facts.destroy_all
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
    system_parameter = SystemParameter.create! :name => "dummy", :value => "value", :reference_id => systems(:one).id
    assert system_parameter
  end

  test "user with create permissions should not be able to create when not permitted" do
    setup_user "create"
    as_admin do
      @one.system_groups = [system_groups(:common)]
      @one.save!
      systems(:one).update_attribute :system_group, system_groups(:unusual)
    end
    record = SystemParameter.create :name => "dummy", :value => "value", :reference_id => systems(:one).id
    assert record.valid?
    assert !record.save
  end

  test "user with create permissions should be able to create when unconstrained" do
    setup_user "create"
    as_admin do
      @one.domains.destroy_all
    end
    system_parameter = SystemParameter.create! :name => "dummy", :value => "value", :reference_id => systems(:one).id
    assert system_parameter
  end

  test "user with view permissions should not be able to create" do
    setup_user "view", "systems"
    record = SystemParameter.create :name => "dummy", :value => "value", :reference_id => systems(:one).id
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  SystemParameter.first
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  SystemParameter.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  SystemParameter.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  SystemParameter.first
    record.name = "renamed"
    assert !record.save
  end
end
