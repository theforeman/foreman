require 'test_helper'

class LookupValueTest < ActiveSupport::TestCase
  def setup
    @host1 = FactoryBot.create(:host)
    @host2 = FactoryBot.create(:host)
  end

  def valid_attrs1
    { :match => "fqdn=#{@host2.name}",
      :value => "3001",
      :lookup_key_id => lookup_keys(:one).id,
    }
  end

  def valid_attrs2
    { :match => "hostgroup=Common",
      :value => "3001",
      :lookup_key_id => lookup_keys(:one).id,
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
      assert lookup_value.update!(:value => "9000")
    end
  end

  test "non-admin user can view only his hosts allowed by filters" do
    # Host.authorized(:view_hosts, Host) returns only hosts(:one)
    user = users(:one)
    role = FactoryBot.create(:role, :name => 'user_view_host_by_ip')
    FactoryBot.create(:filter, :role => role, :permissions => [Permission.find_by_name(:view_hosts)], :search => "name = #{@host1.name}")
    # Todo, restore the ip test variant once our scoped-search works with host.ip again
    # FactoryBot.create(:filter, :role => role, :permissions => [Permission.find_by_name(:view_hosts)], :search => "ip = #{@host1.ip}")
    user.roles << [role]
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

  test "can create lookup value if match fqdn= does match existing host" do
    as_admin do
      Setting[:append_domain_name_for_hosts] = false
      domain = FactoryBot.create(:domain)
      host = FactoryBot.create(:host, interfaces: [FactoryBot.build(:nic_managed, identifier: 'fqdn_test', primary: true, domain: domain)])
      attrs = { :match => "fqdn=#{host.primary_interface.fqdn}", :value => "123", :lookup_key_id => lookup_keys(:one).id }
      refute_match /#{domain.name}/, host.name, "#{host.name} shouldn't be FQDN"
      assert_difference('LookupValue.count') do
        LookupValue.create!(attrs)
      end
    end
  end

  test "can create lookup value if user has matching hostgroup " do
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
    assert_includes lk1.value_before_type_cast, 'foo: bar'

    lk2 = LookupValue.new(:value => "{'foo': 'bar'}", :match => "environment=Production", :lookup_key => lookup_keys(:six))
    assert lk2.save!
    assert lk2.value.is_a? Hash
    assert_includes lk2.value_before_type_cast, 'foo: bar'
  end

  test "should cast and uncast string containing an Array" do
    lk = LookupValue.new(:value => "[{\"foo\":\"bar\"},{\"baz\":\"qux\"},\"baz\"]", :match => "hostgroup=Common", :lookup_key => lookup_keys(:seven))
    assert lk.save!
    assert lk.value.is_a? Array
    assert_equal lk.value_before_type_cast, "[{\"foo\":\"bar\"},{\"baz\":\"qux\"},\"baz\"]"
  end

  test "should not cast string if object invalid" do
    lk = LookupValue.new(:value => '{"foo" => "bar"}', :match => "hostgroup=Common", :lookup_key => lookup_keys(:seven))
    refute lk.valid?
    assert_equal lk.value_before_type_cast, '{"foo" => "bar"}'
  end

  test "shuld not cast string with erb" do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'array', :merge_overrides => true, :avoid_duplicates => true,
      :default_value => [1, 2, 3], :puppetclass => puppetclasses(:one))

    lv = LookupValue.new(:value => "<%= [4,5,6] %>", :match => "hostgroup=Common", :lookup_key => key)
    # does not cast on save (validate_and_cast_value)
    assert lv.save!
    # does not cast on load (value_before_type_cast)
    assert_equal lv.value_before_type_cast, "<%= [4,5,6] %>"
    assert_equal lv.value, "<%= [4,5,6] %>"
  end

  test "boolean lookup value should allow for false value" do
    # boolean key
    key = lookup_keys(:three)
    value = LookupValue.new(:value => false, :match => "hostgroup=Common", :lookup_key_id => key.id)
    assert value.valid?
  end

  test "boolean lookup value should not allow for nil value" do
    # boolean key
    key = lookup_keys(:three)
    value = LookupValue.new(:value => nil, :match => "hostgroup=Common", :lookup_key_id => key.id)
    refute value.valid?
  end

  test "boolean lookup value should allow nil value if omit is true" do
    # boolean key
    key = lookup_keys(:three)
    value = LookupValue.new(:value => nil, :match => "hostgroup=Common", :lookup_key_id => key.id, :omit => true)
    assert_valid value
  end

  test "lookup value should allow valid key" do
    key = lookup_keys(:three)
    value = LookupValue.new(:value => true, :match => "hostgroup=Common", :lookup_key_id => key.id)
    assert_valid value
  end

  test "lookup value should allow valid multiple key" do
    key = lookup_keys(:three)
    value = LookupValue.new(:value => true, :match => "hostgroup=Common,domain=example.com", :lookup_key_id => key.id)
    assert_valid value
  end

  test "lookup value should not allow for nil key" do
    key = lookup_keys(:three)
    value = LookupValue.new(:value => true, :match => "", :lookup_key_id => key.id)
    refute_valid value
  end

  test "lookup value will be rejected for invalid key" do
    key = lookup_keys(:three)
    value = LookupValue.new(:value => true, :match => "hostgroup=", :lookup_key_id => key.id)
    refute_valid value
    assert_equal "is invalid", value.errors[:match].first
  end

  test "lookup value will be rejected for invalid multiple key" do
    key = lookup_keys(:three)
    value = LookupValue.new(:value => true, :match => "hostgroup=Common,domain=", :lookup_key_id => key.id)
    refute_valid value
    assert_equal "is invalid", value.errors[:match].first
  end

  test "lookup value will be rejected for invalid matcher" do
    key = lookup_keys(:three)
    value = LookupValue.new(:value => true, :match => "something=Common", :lookup_key_id => key.id)
    refute_valid value
    assert_equal "something does not exist in order field", value.errors[:match].first
  end

  test "shouldn't save with empty boolean matcher for smart class parameter" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :key_type => 'boolean', :override => true,
                                    :default_value => "true", :description => 'description')
    lookup_value = FactoryBot.build_stubbed(:lookup_value, :lookup_key => lookup_key, :match => "os=fake", :value => '')
    refute lookup_value.valid?
  end

  context "when key is a boolean and default_value is a string" do
    def setup
      @key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
        :override => true, :key_type => 'boolean',
        :default_value => 'whatever', :puppetclass => puppetclasses(:one), :omit => true)
      @value = LookupValue.new(:value => 'abc', :match => "hostgroup=Common", :lookup_key_id => @key.id, :omit => true)
    end

    test "value is not validated if omit is true" do
      assert_valid @value
    end

    test "value is validated if omit is false" do
      @value.omit = false
      refute_valid @value
    end
  end

  context "when key type is puppetclass lookup and value is empty" do
    def setup
      @key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
        :with_override, :with_omit, :path => "hostgroup\ncomment",
                                :key_type => 'string',
                                :puppetclass => puppetclasses(:one))
      @value = FactoryBot.build_stubbed(:lookup_value, :value => "",
                                         :match => "hostgroup=Common",
                                         :lookup_key_id => @key.id,
                                         :omit => true)
    end

    test "value is validated if omit is true" do
      assert_valid @value
    end

    test "value is not validated if omit is false" do
      @value.omit = false
      refute_valid @value
    end
  end

  test "should allow white space in value" do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :with_override, :path => "hostgroup\ncomment",
                             :key_type => 'string',
                             :puppetclass => puppetclasses(:one))
    text = <<~EOF

      this is a multiline value
      with leading and trailing whitespace

    EOF
    value = LookupValue.new(:value => text, :match => "hostgroup=Common", :lookup_key_id => key.id)
    assert value.save!
    assert_equal value.value, text
  end

  test "path should return the correct path for the key" do
    value = LookupValue.new(:match => 'fqdn=abc.example.com')
    assert_equal('fqdn', value.path)
    value.match = "hostgroup=Common,domain=example.com"
    assert_equal('hostgroup,domain', value.path)
  end

  test "should create override value for smart class parameter with list validator and matching value" do
    values_list = ['test', 'example', 30]
    validator_type = 'list'
    validator_rule = values_list.join(', ')
    smart_class_parameter = FactoryBot.create(
      :puppetclass_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :validator_type => validator_type,
      :validator_rule => validator_rule,
      :default_value => 'example'
    )
    match = 'domain=example.com'
    values_list.each do |value|
      sv_lookup_value = FactoryBot.build(
        :lookup_value,
        :lookup_key_id => smart_class_parameter.id,
        :match => match,
        :value => value
      )
      assert sv_lookup_value.valid?
      assert_equal match, sv_lookup_value.match
      assert_equal value, sv_lookup_value.value
    end
  end

  test "can create lookup value with long value" do
    as_user :one do
      lookup_value = LookupValue.new({ :match => "os=Common",
                                       :value => 'a' * 280,
                                       :lookup_key_id => lookup_keys(:complex).id,
                                     })
      assert_difference('LookupValue.count') do
        assert lookup_value.save
      end
    end
  end

  test "should save matcher types as lowercase" do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'string', :path => "HOSTGROUP\nFQDN",
      :default_value => "test123", :puppetclass => puppetclasses(:one))

    lv = LookupValue.new(:value => "lookup_value_lower_test", :match => "HOSTGROUP=Common", :lookup_key => key)
    assert lv.save!
    assert_equal "hostgroup\nfqdn", key.path
    assert_equal "hostgroup=Common", lv.match
  end
end
