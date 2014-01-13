require 'test_helper'

class LookupKeyTest < ActiveSupport::TestCase

  def valid_attrs1
    { :match => "fqdn=#{hosts(:one).name}",
      :value => "false",
      :lookup_key_id => lookup_keys(:three).id
    }
  end

  def valid_attrs2
    { :match => "fqdn=#{hosts(:two).name}",
      :value => "3001",
      :lookup_key_id => lookup_keys(:one).id
    }
  end

  def valid_attrs3
    { :match => "hostgroup=Common",
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

  test "non-admin user cannot view only his hosts restricted by filters" do
    # Host.authorized(:view_hosts, Host) returns only hosts(:one)
    user = users(:one)
    role = FactoryGirl.create(:role, :name => 'user_view_host_by_ip')
    FactoryGirl.create(:filter, :role => role, :permissions => [Permission.find_by_name(:view_hosts)], :search => 'facts.ipaddress = 10.0.19.33')
    user.roles<< [ role ]
    as_user :one do
      assert Host.authorized(:view_hosts, Host).where(:name => hosts(:one).name).exists?
      refute Host.authorized(:view_hosts, Host).where(:name => hosts(:two).name).exists?
    end
  end

  test "any user including admin cannot create lookup value if match fqdn= does not match existing host" do
    as_admin do
      attrs = { :match => "fqdn=non.existing.com", :value => "123", :lookup_key_id => lookup_keys(:one).id }
      lookup_value = LookupValue.new(attrs)
      refute lookup_value.save
      assert_match /Match fqdn=non.existing.com does not match an existing host/, lookup_value.errors.full_messages.join("\n")
    end
  end

  test "any user including admin cannot create lookup value if match hostgroup= does not match existing hostgroup" do
    as_admin do
      attrs = { :match => "hostgroup=non_existing_group", :value => "123", :lookup_key_id => lookup_keys(:one).id }
      lookup_value = LookupValue.new(attrs)
      refute lookup_value.save
      assert_match /Match hostgroup=non_existing_group does not match an existing host group/, lookup_value.errors.full_messages.join("\n")
    end
  end

  test "can create lookup value if user has matching hostgroup " do
    user = users(:one)
    as_admin do
      assert user.hostgroups << hostgroups(:common)
    end
    as_user :one do
      lookup_value = LookupValue.new(valid_attrs3)
      assert_difference('LookupValue.count') do
        assert lookup_value.save
      end
    end
  end

end
