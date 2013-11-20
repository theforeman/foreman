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

  test "looking for a nonexistent host returns no puppetclasses" do
    assert_equal [], Puppetclass.search_for("host = imaginaryhost.nodomain.what")
  end

  test "user with create external_variables permission can create smart variable for puppetclass" do
    @one = users(:one)
    # add permission for user :one
    as_admin do
      filter = FactoryGirl.build(:filter)
      filter.permissions = Permission.find_all_by_name(['edit_puppetclasses', 'create_external_variables'])
      filter.save!
      role = Role.find_or_create_by_name :name => "testing_role"
      role.filters = [ filter ]
      role.save!
      @one.roles = [ role ]
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
