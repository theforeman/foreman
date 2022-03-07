require 'test_helper'

class LookupValueTest < ActiveSupport::TestCase
  let(:host1) { FactoryBot.create(:host) }
  let(:host2) { FactoryBot.create(:host) }
  let(:lookup_key) { FactoryBot.create(:lookup_key, :integer, :path => "hostgroup\nfqdn") }
  let(:string_lookup_key) { FactoryBot.create(:lookup_key, :path => "hostgroup\nfqdn") }
  let(:yaml_lookup_key) { FactoryBot.create(:lookup_key, :yaml, :path => "hostgroup\nfqdn") }
  let(:array_lookup_key) { FactoryBot.create(:lookup_key, :array, :path => "hostgroup\nfqdn") }
  let(:boolean_lookup_key) { FactoryBot.create(:lookup_key, :boolean, :path => "hostgroup\nfqdn\nhostgroup,domain") }

  def valid_attrs1
    { :match => "fqdn=#{host2.name}",
      :value => "3001",
      :lookup_key_id => lookup_key.id,
    }
  end

  def valid_attrs2
    { :match => "hostgroup=Common",
      :value => "3001",
      :lookup_key_id => lookup_key.id,
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

  test "any user including admin cannot create lookup value if match fqdn= does not match existing host" do
    as_admin do
      attrs = { :match => "fqdn=non.existing.com", :value => "123", :lookup_key_id => lookup_key.id }
      lookup_value = LookupValue.new(attrs)
      refute lookup_value.save
      assert_match /Match fqdn=non.existing.com does not match an existing host/, lookup_value.errors.full_messages.join("\n")
    end
  end

  test "any user including admin cannot create lookup value if match hostgroup= does not match existing hostgroup" do
    as_admin do
      attrs = { :match => "hostgroup=non_existing_group", :value => "123", :lookup_key_id => lookup_key.id }
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
      attrs = { :match => "fqdn=#{host.primary_interface.fqdn}", :value => "123", :lookup_key_id => lookup_key.id }
      refute_match /#{domain.name}/, host.name, "#{host.name} shouldn't be FQDN"
      assert_difference('LookupValue.count') do
        LookupValue.create!(attrs)
      end
    end
  end

  test "can create lookup value if user has matching hostgroup " do
    attrs = valid_attrs2 # create key outside as_user
    as_user :one do
      lookup_value = LookupValue.new(attrs)
      assert_difference('LookupValue.count') do
        assert lookup_value.save
      end
    end
  end

  test "accepts valid data" do
    as_admin do
      lk = LookupValue.new(:value => "---\nfoo:\n  bar: baz", :match => "hostgroup=Common", :lookup_key => yaml_lookup_key)
      assert lk.valid?
      assert lk.save!
    end
  end

  test "validation detects invalid data" do
    as_admin do
      lk = LookupValue.new(:value => "---\n[[\n;", :match => "hostgroup=Common", :lookup_key => yaml_lookup_key)
      refute lk.valid?
      assert lk.errors.messages[:value].include? "is invalid yaml"
    end
  end

  test "should cast and uncast string containing a Hash" do
    lk1 = LookupValue.new(:value => "---\n  foo: bar", :match => "hostgroup=Common", :lookup_key => yaml_lookup_key)
    assert lk1.save!
    assert lk1.value.is_a? Hash
    assert_includes lk1.value_before_type_cast, 'foo: bar'

    lk2 = LookupValue.new(:value => "{'foo': 'bar'}", :match => "hostgroup=Parent", :lookup_key => yaml_lookup_key)
    assert lk2.save!
    assert lk2.value.is_a? Hash
    assert_includes lk2.value_before_type_cast, 'foo: bar'
  end

  test "should cast and uncast string containing an Array" do
    lk = LookupValue.new(:value => "[{\"foo\":\"bar\"},{\"baz\":\"qux\"},\"baz\"]", :match => "hostgroup=Common", :lookup_key => array_lookup_key)
    assert lk.save!
    assert lk.value.is_a? Array
    assert_equal lk.value_before_type_cast, "[{\"foo\":\"bar\"},{\"baz\":\"qux\"},\"baz\"]"
  end

  test "should not cast string if object invalid" do
    lk = LookupValue.new(:value => '{"foo" => "bar"}', :match => "hostgroup=Common", :lookup_key => array_lookup_key)
    refute lk.valid?
    assert_equal lk.value_before_type_cast, '{"foo" => "bar"}'
  end

  test "shuld not cast string with erb" do
    key = FactoryBot.create(:lookup_key, :array, override: true, merge_overrides: true, avoid_duplicates: true, default_value: [1, 2, 3])
    lv = LookupValue.new(:value => "<%= [4,5,6] %>", :match => "hostgroup=Common", :lookup_key => key)
    # does not cast on save (validate_and_cast_value)
    assert lv.save!
    # does not cast on load (value_before_type_cast)
    assert_equal lv.value_before_type_cast, "<%= [4,5,6] %>"
    assert_equal lv.value, "<%= [4,5,6] %>"
  end

  test "boolean lookup value should allow for false value" do
    value = LookupValue.new(:value => false, :match => "hostgroup=Common", :lookup_key_id => boolean_lookup_key.id)
    assert value.valid?
  end

  test "lookup value should allow valid key" do
    value = LookupValue.new(:value => true, :match => "hostgroup=Common", :lookup_key_id => boolean_lookup_key.id)
    assert_valid value
  end

  test "lookup value should allow valid multiple key" do
    value = LookupValue.new(:value => true, :match => "hostgroup=Common,domain=example.com", :lookup_key_id => boolean_lookup_key.id)
    assert_valid value
  end

  test "lookup value should not allow for blank key" do
    value = LookupValue.new(:value => true, :match => "", :lookup_key_id => boolean_lookup_key.id)
    refute_valid value
  end

  test "lookup value should not allow for nil key" do
    value = LookupValue.new(:value => true, :match => nil, :lookup_key_id => boolean_lookup_key.id)
    refute value.save
  end

  test "lookup value will be rejected for invalid key" do
    value = LookupValue.new(:value => true, :match => "hostgroup=", :lookup_key_id => boolean_lookup_key.id)
    refute_valid value
    assert_equal "is invalid", value.errors[:match].first
  end

  test "lookup value will be rejected for invalid multiple key" do
    value = LookupValue.new(:value => true, :match => "hostgroup=Common,domain=", :lookup_key_id => boolean_lookup_key.id)
    refute_valid value
    assert_equal "is invalid", value.errors[:match].first
  end

  test "lookup value will be rejected for invalid matcher" do
    value = LookupValue.new(:value => true, :match => "something=Common", :lookup_key_id => boolean_lookup_key.id)
    refute_valid value
    assert_equal "something does not exist in order field", value.errors[:match].first
  end

  test "should allow white space in value" do
    text = <<~EOF

      this is a multiline value
      with leading and trailing whitespace

    EOF
    value = LookupValue.new(:value => text, :match => "hostgroup=Common", :lookup_key_id => string_lookup_key.id)
    assert value.save!
    assert_equal value.value, text
  end

  test "path should return the correct path for the key" do
    value = LookupValue.new(:match => 'fqdn=abc.example.com')
    assert_equal('fqdn', value.path)
    value.match = "hostgroup=Common,domain=example.com"
    assert_equal('hostgroup,domain', value.path)
  end

  test "should create override value for lookup key with list validator and matching value" do
    values_list = ['test', 'example', 30]
    validator_type = 'list'
    validator_rule = values_list.join(', ')
    lookup_key = FactoryBot.create(
      :lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :validator_type => validator_type,
      :validator_rule => validator_rule,
      :default_value => 'example'
    )
    match = 'domain=example.com'
    values_list.each do |value|
      sv_lookup_value = FactoryBot.build(
        :lookup_value,
        :lookup_key_id => lookup_key.id,
        :match => match,
        :value => value
      )
      assert sv_lookup_value.valid?
      assert_equal match, sv_lookup_value.match
      assert_equal value, sv_lookup_value.value
    end
  end

  test "can create lookup value with long value" do
    lookup_value = LookupValue.new({ :match => "hostgroup=Common",
                                     :value => 'a' * 280,
                                     :lookup_key_id => string_lookup_key.id,
                                   })
    assert_difference('LookupValue.count') do
      assert lookup_value.save
    end
  end

  test "should save matcher types as lowercase" do
    key = FactoryBot.create(:lookup_key, :path => "HOSTGROUP\nFQDN")
    lv = LookupValue.new(:value => "lookup_value_lower_test", :match => "HOSTGROUP=Common", :lookup_key => key)
    assert lv.save!
    assert_equal "hostgroup\nfqdn", key.path
    assert_equal "hostgroup=Common", lv.match
  end
end
