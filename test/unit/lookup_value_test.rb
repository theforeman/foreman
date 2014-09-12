require 'test_helper'

class LookupValueTest < ActiveSupport::TestCase

  def setup
    @host1 = FactoryGirl.create(:host)
    @host2 = FactoryGirl.create(:host)
  end

  def valid_attrs1
    { :match => "fqdn=#{@host2.name}",
      :value => "3001",
      :lookup_key_id => lookup_keys(:one).id
    }
  end

  def valid_attrs2
    { :match => "hostgroup=Common",
      :value => "3001",
      :lookup_key_id => lookup_keys(:one).id
    }
  end

  test "create lookup value by admin" do
    as_admin do
      assert_difference('LookupValue.count') do
        LookupValue.create!(valid_attrs1)
      end
    end
  end

  test "update lookup value by admin" do
    lookup_value = lookup_values(:hostgroupcommon)
    as_admin do
      assert lookup_value.update_attributes!(:value => "9000")
    end
  end

  test "non-admin user cannot view only his hosts restricted by filters" do
    # Host.authorized(:view_hosts, Host) returns only hosts(:one)
    user = users(:one)
    role = FactoryGirl.create(:role, :name => 'user_view_host_by_ip')
    FactoryGirl.create(:filter, :role => role, :permissions => [Permission.find_by_name(:view_hosts)], :search => "ip = #{@host1.ip}")
    user.roles<< [ role ]
    as_user :one do
      assert Host.authorized(:view_hosts, Host).where(:name => @host1.name).exists?
      refute Host.authorized(:view_hosts, Host).where(:name => @host2.name).exists?
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
    as_user :one do
      lookup_value = LookupValue.new(valid_attrs2)
      assert_difference('LookupValue.count') do
        assert lookup_value.save
      end
    end
  end

  test "smart class parameter accepts valid data" do
    as_admin do
      lk = LookupValue.new(:value => "---\nfoo:\n  bar: baz", :match => "hostgroup=Common", :lookup_key => lookup_keys(:six))
      assert lk.valid?
      assert lk.save!
    end
  end

  test "smart class parameter validation detects invalid data" do
    as_admin do
      lk = LookupValue.new(:value => "---\n[[\n;", :match => "hostgroup=Common", :lookup_key => lookup_keys(:six))
      refute lk.valid?
      assert lk.errors.messages[:value].include? "is invalid yaml"
    end
  end

  test "should cast and uncast string containing a Hash" do
    lk1 = LookupValue.new(:value => "---\n  foo: bar", :match => "hostgroup=Common", :lookup_key => lookup_keys(:six))
    assert lk1.save!
    assert lk1.value.is_a? Hash
    assert_equal lk1.value_before_type_cast, "foo: bar\n"

    lk2 = LookupValue.new(:value => "{'foo': 'bar'}", :match => "environment=Production", :lookup_key => lookup_keys(:six))
    assert lk2.save!
    assert lk2.value.is_a? Hash
    assert_equal lk2.value_before_type_cast, "foo: bar\n"
  end

  test "should cast and uncast string containing an Array" do
    lk = LookupValue.new(:value => "[{\"foo\":\"bar\"},{\"baz\":\"qux\"},\"baz\"]", :match => "hostgroup=Common", :lookup_key => lookup_keys(:seven))
    assert lk.save!
    assert lk.value.is_a? Array
    assert_equal lk.value_before_type_cast, "[{\"foo\":\"bar\"},{\"baz\":\"qux\"},\"baz\"]"
  end

  test "when created, an audit entry should be added" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :with_parameters, :environments => [env])
    key = pc.class_params.first
    lvalue = nil
    assert_difference('Audit.count') do
      lvalue = FactoryGirl.create :lookup_value, :lookup_key_id => key.id, :value => 'test', :match => 'foo=bar'
    end
    assert_equal "#{pc.name}::#{key.key}", lvalue.audits.last.associated_name
  end

  test "when changed, an audit entry should be added" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :environments => [env])
    key = FactoryGirl.create(:lookup_key, :as_smart_class_param, :with_override, :puppetclass => pc)
    lvalue = key.lookup_values.first
    assert_difference('Audit.count') do
      lvalue.value = 'new overridden value'
      lvalue.save!
    end
    assert_equal "#{pc.name}::#{key.key}", lvalue.audits.last.associated_name
  end
end
