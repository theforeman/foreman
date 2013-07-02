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

  test "cannot create lookup value if user has no matching host/hostgroup" do
    # Host.my_hosts returns only hosts(:one)
    user = users(:one)
    as_user :one do
      refute Host.my_hosts.where(:name => hosts(:two).name).exists?
      refute Hostgroup.my_groups.where(:name => hosts(:two).try(:hostgroup).try(:name)).exists?
      lookup_value = LookupValue.new(valid_attrs2)
      refute lookup_value.save
    end
  end

  test "cannot update lookup value if user has no matching host/hostgroup" do
    # Host.my_hosts returns only hosts(:one)
    user = users(:one)
    as_user :one do
      refute Host.my_hosts.where(:name => hosts(:two).name).exists?
      refute Hostgroup.my_groups.where(:name => hosts(:two).try(:hostgroup).try(:name)).exists?
      refute lookup_values(:hosttwo).update_attributes(:value => "9000")
    end
  end

  test "can create lookup value if user has matching host " do
    # Host.my_hosts returns only hosts(:one)
    user = users(:one)
    as_user :one do
      assert Host.my_hosts.where(:name => hosts(:one).name).exists?
      refute Hostgroup.my_groups.where(:name => hosts(:one).try(:hostgroup).try(:name)).exists?
      lookup_value = LookupValue.new(valid_attrs1)
      assert_difference('LookupValue.count') do
        assert lookup_value.save
      end
    end
  end

  test "can update lookup value if user has matching host " do
    # Host.my_hosts returns only hosts(:one)
    user = users(:one)
    as_user :one do
      assert Host.my_hosts.where(:name => hosts(:one).name).exists?
      refute Hostgroup.my_groups.where(:name => hosts(:one).try(:hostgroup).try(:name)).exists?
      assert lookup_values(:one).update_attributes(:value => "9000")
    end
  end

  test "can create lookup value if user has matching hostgroup " do
    # Host.my_hosts returns only hosts(:one)
    user = users(:one)
    as_admin do
      assert user.hostgroups << hostgroups(:common)
    end
    as_user :one do
      assert Hostgroup.my_groups.where(:name => "Common").exists?
      lookup_value = LookupValue.new(valid_attrs3)
      assert_difference('LookupValue.count') do
        assert lookup_value.save
      end
    end
  end

  test "can update lookup value if user has matching hostgroup " do
    # Host.my_hosts returns only hosts(:one)
    user = users(:one)
    as_admin do
      assert user.hostgroups << hostgroups(:common)
    end
    as_user :one do
      assert Hostgroup.my_groups.where(:name => "Common").exists?
      assert lookup_values(:hostgroupcommon).update_attributes(:value => "9000")
    end
  end

end
