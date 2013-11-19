require 'test_helper'

class LookupKeyTest < ActiveSupport::TestCase

  def valid_attrs1
    { :match => "fqdn=#{systems(:one).name}",
      :value => "false",
      :lookup_key_id => lookup_keys(:three).id
    }
  end

  def valid_attrs2
    { :match => "fqdn=#{systems(:two).name}",
      :value => "3001",
      :lookup_key_id => lookup_keys(:one).id
    }
  end

  def valid_attrs3
    { :match => "system_group=Common",
      :value => "3001",
      :lookup_key_id => lookup_keys(:one).id
    }
  end

  test "create lookup value by admin" do
    as_admin do
      assert_difference('LookupValue.count') do
        LookupValue.create!(valid_attrs2)
      end
    end
  end

  test "update lookup value by admin" do
    lookup_value = lookup_values(:one)
    as_admin do
      assert lookup_value.update_attributes!(:value => "9000")
    end
  end

  test "non-admin user cannot create lookup value if user has no matching system/system_group" do
    # System.my_systems returns only systems(:one)
    user = users(:one)
    as_user :one do
      refute System.my_systems.where(:name => systems(:two).name).exists?
      refute SystemGroup.my_groups.where(:name => systems(:two).try(:system_group).try(:name)).exists?
      lookup_value = LookupValue.new(valid_attrs2)
      refute lookup_value.save
    end
  end

  test "any user including admin cannot create lookup value if match fqdn= does not match existing system" do
    as_admin do
      attrs = { :match => "fqdn=non.existing.com", :value => "123", :lookup_key_id => lookup_keys(:one).id }
      lookup_value = LookupValue.new(attrs)
      refute lookup_value.save
      assert_match /Match fqdn=non.existing.com does not match an existing system/, lookup_value.errors.full_messages.join("\n")
    end
  end

  test "any user including admin cannot create lookup value if match system_group= does not match existing system_group" do
    as_admin do
      attrs = { :match => "system_group=non_existing_group", :value => "123", :lookup_key_id => lookup_keys(:one).id }
      lookup_value = LookupValue.new(attrs)
      refute lookup_value.save
      assert_match /Match system_group=non_existing_group does not match an existing system group/, lookup_value.errors.full_messages.join("\n")
    end
  end

  test "cannot update lookup value if user has no matching system/system_group" do
    # System.my_systems returns only systems(:one)
    user = users(:one)
    as_user :one do
      refute System.my_systems.where(:name => systems(:two).name).exists?
      refute SystemGroup.my_groups.where(:name => systems(:two).try(:system_group).try(:name)).exists?
      refute lookup_values(:systemtwo).update_attributes(:value => "9000")
    end
  end

  test "can create lookup value if user has matching system " do
    # System.my_systems returns only systems(:one)
    user = users(:one)
    as_user :one do
      assert System.my_systems.where(:name => systems(:one).name).exists?
      refute SystemGroup.my_groups.where(:name => systems(:one).try(:system_group).try(:name)).exists?
      lookup_value = LookupValue.new(valid_attrs1)
      assert_difference('LookupValue.count') do
        assert lookup_value.save
      end
    end
  end

  test "can update lookup value if user has matching system " do
    # System.my_systems returns only systems(:one)
    user = users(:one)
    as_user :one do
      assert System.my_systems.where(:name => systems(:one).name).exists?
      refute SystemGroup.my_groups.where(:name => systems(:one).try(:system_group).try(:name)).exists?
      assert lookup_values(:one).update_attributes(:value => "9000")
    end
  end

  test "can create lookup value if user has matching system_group " do
    # System.my_systems returns only systems(:one)
    user = users(:one)
    as_admin do
      assert user.system_groups << system_groups(:common)
    end
    as_user :one do
      assert SystemGroup.my_groups.where(:name => "Common").exists?
      lookup_value = LookupValue.new(valid_attrs3)
      assert_difference('LookupValue.count') do
        assert lookup_value.save
      end
    end
  end

  test "can update lookup value if user has matching system_group " do
    # System.my_systems returns only systems(:one)
    user = users(:one)
    as_admin do
      assert user.system_groups << system_groups(:common)
    end
    as_user :one do
      assert SystemGroup.my_groups.where(:name => "Common").exists?
      assert lookup_values(:system_groupcommon).update_attributes(:value => "9000")
    end
  end

end
