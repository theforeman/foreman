require 'test_helper'

class CommonParameterTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end
  test "name can't be blank" do
    parameter = CommonParameter.new :name => "  ", :value => "some_value"
    assert parameter.name.strip.empty?
    assert !parameter.save
  end

  test "name can't contain trailing spaces" do
    parameter = CommonParameter.new :name => "   a new     param    ", :value => "some_value"
    assert !parameter.name.strip.squeeze(" ").empty?
    assert !parameter.save

    parameter.name.strip!.squeeze!(" ")
    assert parameter.save
  end

  test "value can't be blank" do
    parameter = CommonParameter.new :name => "some parameter", :value => "   "
    assert parameter.value.strip.empty?
    assert !parameter.save
  end

  test "value can't be empty" do
    parameter = CommonParameter.new :name => "some parameter", :value => ""
    assert parameter.value.strip.empty?
    assert !parameter.save
  end

  test "value can't contain trailing spaces" do
    parameter = CommonParameter.new :name => "some parameter", :value => "   some crazy      value    "
    assert !parameter.value.strip.squeeze(" ").empty?
    assert !parameter.save

    parameter.value.strip!.squeeze!(" ").empty?
    assert parameter.save
  end

  test "value can contain spaces and unusual characters" do
    parameter = CommonParameter.new :name => "some parameter", :value => "   some crazy \"\'&<*%£# value"
    assert !parameter.value.strip.squeeze(" ").empty?
    assert parameter.save

    parameter.value.strip!.squeeze!(" ").empty?
    assert parameter.save
  end

  test "duplicate names cannot exist" do
    parameter1 = CommonParameter.create :name => "some parameter", :value => "value"
    parameter2 = CommonParameter.create :name => "some parameter", :value => "value"
    assert !parameter2.valid?
    assert  parameter2.errors.full_messages[0] == "Name has already been taken"
  end

  def setup_user operation
    @one = users(:one)
    as_admin do
      role = Role.find_or_create_by_name :name => "#{operation}_global_variables"
      role.permissions = ["#{operation}_global_variables".to_sym]
      @one.roles = [role]
      @one.save!
    end
    User.current = @one
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  CommonParameter.create :name => "dummy", :value => "value"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  CommonParameter.create :name => "dummy", :value => "value"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  CommonParameter.first
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  CommonParameter.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  CommonParameter.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  CommonParameter.first
    record.name = "renamed"
    assert !record.save
  end

end
