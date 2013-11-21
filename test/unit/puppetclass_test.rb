require 'test_helper'

class PuppetclassTest < ActiveSupport::TestCase
  setup do
    User.current = User.find_by_login "admin"
  end

  test "name can't be blank" do
    puppet_class = Puppetclass.new
    assert !puppet_class.save
  end

  test "name can't contain trailing white spaces" do
    puppet_class = Puppetclass.new :name => "   test     class   "
    assert !puppet_class.name.squeeze(" ").empty?
    assert !puppet_class.save

    puppet_class.name.squeeze!(" ")
    assert puppet_class.save
  end

  test "name must be unique" do
    puppet_class = Puppetclass.new :name => "test class"
    assert puppet_class.save

    other_puppet_class = Puppetclass.new :name => "test class"
    assert !other_puppet_class.save
  end

  def setup_user operation
    super operation, "puppetclasses"
  end

  test "user with create permissions should be able to create" do
    setup_user "create"
    record =  Puppetclass.create :name => "dummy"
    assert record.valid?
    assert !record.new_record?
  end

  test "user with view permissions should not be able to create" do
    setup_user "view"
    record =  Puppetclass.create :name => "dummy"
    assert record.valid?
    assert record.new_record?
  end

  test "user with destroy permissions should be able to destroy" do
    setup_user "destroy"
    record =  Puppetclass.first
    as_admin do
      record.hosts.destroy_all
      record.lookup_keys.destroy_all
    end
    assert record.destroy
    assert record.frozen?
  end

  test "user with edit permissions should not be able to destroy" do
    setup_user "edit"
    record =  Puppetclass.first
    assert !record.destroy
    assert !record.frozen?
  end

  test "user with edit permissions should be able to edit" do
    setup_user "edit"
    record      =  Puppetclass.first
    record.name = "renamed"
    assert record.save
  end

  test "user with destroy permissions should not be able to edit" do
    setup_user "destroy"
    record      =  Puppetclass.first
    record.name = "renamed"
    as_admin do
      record.hosts.destroy_all
    end
    assert !record.save
    assert record.valid?
  end

  test "looking for a nonexistent host returns no puppetclasses" do
    assert_equal [], Puppetclass.search_for("host = imaginaryhost.nodomain.what")
  end

  test "user without create external_variables permission cannot create smart variable for puppetclass" do
    setup_user "edit"
    nested_lookup_key_params = {:new_1372154591368 => {:key=>"test_param", :key_type=>"string", :default_value => "7777", :path =>"fqdn\r\nhostgroup\r\nos\r\ndomain"}}
    refute Puppetclass.first.update_attributes(:lookup_keys_attributes => nested_lookup_key_params)
  end

  test "user with create external_variables permission can create smart variable for puppetclass" do
    @one = users(:one)
    # add permission for user :one
    as_admin do
      role = Role.find_or_create_by_name :name => "testing_role"
      role.permissions = [:edit_puppetclasses, :create_external_variables]
      role.save!
      @one.roles = [role]
      @one.save!
    end
    as_user :one do
      nested_lookup_key_params = {:new_1372154591368 => {:key=>"test_param", :key_type=>"string", :default_value => "7777", :path =>"fqdn\r\nhostgroup\r\nos\r\ndomain"}}
      assert Puppetclass.first.update_attributes(:lookup_keys_attributes => nested_lookup_key_params)
    end
  end

  test "create puppetclass with smart variable as nested attribute" do
    as_admin do
      puppetclass = Puppetclass.new(:name => "PuppetclassWithSmartVariable", :lookup_keys_attributes => {"new_1372154591368" => {:key => 'smart_variable1'}})
      assert puppetclass.save
      assert_equal Puppetclass.unscoped.last.id, LookupKey.unscoped.last.puppetclass_id
    end
  end

  test "Puppetclass singularize from custom inflection" do
    assert_equal "Puppetclass", "Puppetclass".singularize
    assert_equal "Puppetclass", "Puppetclasses".singularize
    assert_equal "puppetclass", "puppetclass".singularize
    assert_equal "puppetclass", "puppetclasses".singularize
  end

  test "Puppetclass classify from custom inflection" do
    assert_equal "Puppetclass", "Puppetclass".classify
    assert_equal "Puppetclass", "Puppetclasses".classify
    assert_equal "Puppetclass", "puppetclass".classify
    assert_equal "Puppetclass", "puppetclasses".classify
  end

end
