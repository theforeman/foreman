require 'test_helper'

class LookupKeyTest < ActiveSupport::TestCase
  def setup
    @host1, @host2, @host3 = FactoryBot.create_list(:host, 3,
      :location      => taxonomies(:location1),
      :organization  => taxonomies(:organization1),
      :puppetclasses => [puppetclasses(:one)],
      :environment   => environments(:production))
  end

  should validate_presence_of(:key)
  should validate_inclusion_of(:validator_type).
    in_array(LookupKey::VALIDATOR_TYPES).allow_blank.allow_nil.
    with_message('invalid')
  should validate_inclusion_of(:key_type).
    in_array(LookupKey::KEY_TYPES).allow_blank.allow_nil.
    with_message('invalid')

  def test_element_seperations
    key = ""
    as_admin do
      key = PuppetclassLookupKey.create!(:key => "ntp", :path => "domain,hostgroup\n domain")
    end
    elements = key.send(:path_elements) # hack to access private method
    assert_equal "domain", elements[0][0]
    assert_equal "hostgroup", elements[0][1]
    assert_equal "domain", elements[1][0]
  end

  def test_fetching_the_correct_value_to_a_given_key
    key   = ""
    value = ""
    puppetclass = puppetclasses(:one)

    as_admin do
      key   = PuppetclassLookupKey.create!(:key => "dns", :path => "domain\npuppetversion", :override => true)
      value = LookupValue.create!(:value => "[1.2.3.4,2.3.4.5]", :match => "domain =  mydomain.net", :lookup_key => key)
      EnvironmentClass.create!(:puppetclass => puppetclass, :environment => environments(:production),
                               :puppetclass_lookup_key => key)
    end

    key.reload
    assert key.lookup_values.count > 0
    @host1.domain = domains(:mydomain)

    assert_equal value.value, HostInfoProviders::PuppetInfo.new(@host1).puppetclass_parameters['base']['dns']
  end

  def test_multiple_paths
    @host1.hostgroup = hostgroups(:common)
    @host1.environment = environments(:testing)

    @host2.hostgroup = hostgroups(:unusual)
    @host2.environment = environments(:testing)

    @host3.environment = environments(:testing)

    default = "default"
    key = ""
    value1 = ""
    value2 = ""
    puppetclass = Puppetclass.first
    as_admin do
      key    = PuppetclassLookupKey.create!(:key => "dns", :path => "environment,hostgroup\nhostgroup\nfqdn", :default_value => default, :override => true)
      value1 = LookupValue.create!(:value => "v1", :match => "environment=testing,hostgroup=Common", :lookup_key => key)
      value2 = LookupValue.create!(:value => "v2", :match => "hostgroup=Unusual", :lookup_key => key)

      LookupValue.create!(:value => "v22", :match => "fqdn=#{@host2.fqdn}", :lookup_key => key)
      EnvironmentClass.create!(:puppetclass => puppetclass, :environment => environments(:testing),
                               :puppetclass_lookup_key => key)
      HostClass.create!(:host => @host1, :puppetclass => puppetclass)
      HostClass.create!(:host => @host2, :puppetclass => puppetclass)
      HostClass.create!(:host => @host3, :puppetclass => puppetclass)
    end

    key.reload

    assert_equal value1.value, HostInfoProviders::PuppetInfo.new(@host1).puppetclass_parameters['apache']['dns']
    assert_equal value2.value, HostInfoProviders::PuppetInfo.new(@host2).puppetclass_parameters['apache']['dns']
    assert_equal default, HostInfoProviders::PuppetInfo.new(@host3).puppetclass_parameters['apache']['dns']
    assert key.overridden?(@host2)
    refute key.overridden?(@host1)
  end

  test 'default_value value should not be casted if override is false' do
    param = FactoryBot.build(:puppetclass_lookup_key, :as_smart_class_param,
      :override => false, :key_type => 'boolean',
      :default_value => 't', :puppetclass => puppetclasses(:one))
    param.save
    assert_equal 't', param.default_value
    param.override = true
    param.save
    assert_equal true, param.default_value
  end

  describe '#default_value_before_type_cast' do
    test 'nil value should remain nil' do
      param = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
        :override => true, :key_type => 'string',
        :default_value => nil, :puppetclass => puppetclasses(:one))
      param.valid?
      assert_nil param.default_value
      assert_nil param.default_value_before_type_cast
    end

    test 'boolean value should remain casted' do
      param = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
        :override => true, :key_type => 'boolean',
        :default_value => 'false', :puppetclass => puppetclasses(:one))
      param.valid?
      assert_equal false, param.default_value
      assert_equal false, param.default_value_before_type_cast
    end

    test 'array value should be an unchanged string' do
      param = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
        :override => true, :key_type => 'array',
        :default_value => '["test"]', :puppetclass => puppetclasses(:one))
      default = param.default_value
      param.valid?
      assert_equal ['test'], param.default_value
      assert_equal default, param.default_value_before_type_cast
    end

    test 'JSON value should be an unchanged string' do
      param = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
        :override => true, :key_type => 'json',
        :default_value => '["test"]', :puppetclass => puppetclasses(:one))
      default = param.default_value
      param.valid?
      assert_equal ['test'], param.default_value
      assert_equal default, param.default_value_before_type_cast
    end

    test 'hash value should be an unchanged string' do
      param = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
        :override => true, :key_type => 'hash',
        :default_value => "foo: bar\n", :puppetclass => puppetclasses(:one))
      param.valid?
      assert_equal({'foo' => 'bar'}, param.default_value)
      assert_equal "foo: bar\n", param.default_value_before_type_cast
    end

    test 'YAML value should be an unchanged string' do
      param = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
        :override => true, :key_type => 'yaml',
        :default_value => "- test\n", :puppetclass => puppetclasses(:one))
      param.valid?
      assert_equal ['test'], param.default_value
      assert_equal "- test\n", param.default_value_before_type_cast
    end

    test 'uncast value containing ERB should be an unchanged string' do
      param = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
        :override => true, :key_type => 'array',
        :default_value => '["<%= @host.name %>"]', :puppetclass => puppetclasses(:one))
      default = param.default_value
      param.valid?
      assert_equal '["<%= @host.name %>"]', param.default_value
      assert_equal default, param.default_value_before_type_cast
    end

    test "when invalid, just returns the invalid value" do
      val = '{"foo" => "bar"}'
      param = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
        :override => true, :key_type => 'hash',
        :default_value => val, :puppetclass => puppetclasses(:one))
      refute param.valid?
      assert_equal val, param.default_value_before_type_cast
    end

    test "white space isn't stripped" do
      val = <<~EOF

        this is a multiline value
        with leading and trailing whitespace

      EOF
      param = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
        :override => true, :key_type => 'string',
        :default_value => val, :puppetclass => puppetclasses(:one))
      assert param.valid?
      assert_equal val, param.default_value_before_type_cast
    end
  end
  test "this is a smart class parameter?" do
    assert_not_deprecated do
      assert lookup_keys(:complex).puppet?
    end
  end

  test "to_param should replace whitespace with underscore" do
    lookup_key = PuppetclassLookupKey.new(:key => "smart variable", :path => "hostgroup",
                                          :default_value => "default")
    assert_equal "-smart_variable", lookup_key.to_param
  end

  test "should not be able to merge overrides for a string" do
    key = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'string', :merge_overrides => true,
      :puppetclass => puppetclasses(:one))
    refute_valid key
    assert_equal key.errors[:merge_overrides].first, _("can only be set for array or hash")
  end

  test "should be able to merge overrides for a hash" do
    key = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'hash', :merge_overrides => true,
      :default_value => {}, :puppetclass => puppetclasses(:one))
    assert_valid key
  end

  test "should be able to merge overrides with default_value for a hash" do
    key = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'hash', :merge_overrides => true, :merge_default => true,
      :default_value => {}, :puppetclass => puppetclasses(:one))
    assert_valid key
  end

  test "should not be able to merge default when merge_override is false" do
    key = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'hash', :merge_overrides => false, :merge_default => true,
      :default_value => {}, :puppetclass => puppetclasses(:one))
    refute_valid key
    assert_equal "can only be set when merge overrides is set", key.errors[:merge_default].first
  end

  test "should not be able to avoid duplicates for a hash" do
    key = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'hash', :merge_overrides => true, :avoid_duplicates => true,
      :default_value => {}, :puppetclass => puppetclasses(:one))
    refute_valid key
    assert_equal key.errors[:avoid_duplicates].first, _("can only be set for arrays that have merge_overrides set to true")
  end

  test "should be able to merge overrides for a array" do
    key = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'array', :merge_overrides => true, :avoid_duplicates => true,
      :default_value => [], :puppetclass => puppetclasses(:one))
    assert_valid key
  end

  test "should not be able to avoid duplicates when merge_override is false" do
    key = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'array', :merge_overrides => false, :avoid_duplicates => true,
      :default_value => [], :puppetclass => puppetclasses(:one))
    refute_valid key
    assert_equal key.errors[:avoid_duplicates].first, _("can only be set for arrays that have merge_overrides set to true")
  end

  test "array key is valid even with string value containing erb" do
    key = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'array', :merge_overrides => true, :avoid_duplicates => true,
      :default_value => '<%= [1,2,3] %>', :puppetclass => puppetclasses(:one))
    assert key.valid?
  end

  test "array key is invalid with string value without erb" do
    key = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'array', :merge_overrides => true, :avoid_duplicates => true,
      :default_value => 'whatever', :puppetclass => puppetclasses(:one))
    refute key.valid?
    assert_include key.errors.keys, :default_value
  end

  test "safe_value can be shown for key" do
    key = FactoryBot.build_stubbed(:puppetclass_lookup_key, :as_smart_class_param, :hidden_value => false,
                            :override => true, :key_type => 'string',
                            :default_value => 'aaa', :puppetclass => puppetclasses(:one))
    assert_equal key.default_value, key.safe_value
    key.hidden_value = true
    assert_equal key.hidden_value, key.safe_value
  end

  context "when key is a boolean and default_value is a string" do
    def setup
      @key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
        :override => true, :key_type => 'boolean',
        :default_value => 'whatever', :puppetclass => puppetclasses(:one), :omit => true)
    end

    test "default_value is not validated if omit is true" do
      assert @key.valid?
    end

    test "default_value is validated if omit is false" do
      @key.omit = false
      refute @key.valid?
    end
  end

  test "override params are reset after override changes back to false" do
    @key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'array',
      :default_value => '[]', :puppetclass => puppetclasses(:one),
      :omit => true)
    override_params = [:merge_overrides, :merge_default, :avoid_duplicates]

    override_params.each { |param| @key.send("#{param}=", true) }
    @key.save

    @key.override = false
    @key.description = "Gregor Samsa"

    assert @key.save
    refute @key.errors.any?
    override_params.each { |param| assert_equal false, @key.read_attribute(param) }
  end

  test "#overridden? works for unsaved hosts" do
    key = FactoryBot.create(:puppetclass_lookup_key)
    host = FactoryBot.build_stubbed(:host)
    refute key.overridden?(host)

    host.lookup_values_attributes = {'0' => {'lookup_key_id' => key.id.to_s, '_destroy' => 'false'}}.with_indifferent_access
    assert_equal 1, host.lookup_values.size
    assert key.overridden?(host)
  end

  test 'sorted_values returns correctly ordered values' do
    key = FactoryBot.create(:puppetclass_lookup_key, :path => "model\nos\r\narch\nos,model")
    value1 = LookupValue.create(:lookup_key => key, :match => "os=test", :value => "aaa")
    value2 = LookupValue.create(:lookup_key => key, :match => "os=test2,model=a", :value => "aaa")
    value3 = LookupValue.create(:lookup_key => key, :match => "model=testmodel", :value => "aaa")
    value4 = LookupValue.create(:lookup_key => key, :match => "arch=testarcg", :value => "aaa")
    value5 = LookupValue.create(:lookup_key => key, :match => "arch=testaaaa", :value => "bcd")

    assert_equal([value3, value1, value5, value4, value2], key.sorted_values)
    refute_equal([value3, value1, value5, value4, value2], key.lookup_values)
  end

  test 'should not update with invalid parameter types' do
    invalid_parameters_data = [
      {
        :sc_type => 'boolean',
        :value => RFauxFactory.gen_alphanumeric,
      },
      {
        :sc_type => 'integer',
        :value => RFauxFactory.gen_utf8,
      },
      {
        :sc_type => 'real',
        :value => RFauxFactory.gen_utf8,
      },
      {
        :sc_type => 'array',
        :value => '0',
      },
      {
        :sc_type => 'hash',
        :value => 'a:test',
      },
      {
        :sc_type => 'yaml',
        :value => '{a:test}',
      },
      {
        :sc_type => 'json',
        :value => RFauxFactory.gen_alpha,
      },
    ]
    lookup_key = lookup_keys(:five)
    invalid_parameters_data.each do |data|
      lookup_key.parameter_type = data[:sc_type]
      lookup_key.default_value = data[:value]
      refute lookup_key.valid?, "Can update lookup key with invalid data #{data}"
      assert_includes lookup_key.errors.keys, :default_value
    end
  end

  test 'should update with valid parameter types' do
    valid_parameters_data = [
      {
        :sc_type => 'string',
        :value => RFauxFactory.gen_utf8,
      },
      {
        :sc_type => 'boolean',
        :value => ['0', '1'].sample,
      },
      {
        :sc_type => 'integer',
        :value => rand(1000..1 << 64),
      },
      {
        :sc_type => 'real',
        :value => -123.0,
      },
      {
        :sc_type => 'array',
        :value => "[#{RFauxFactory.gen_alpha}, #{RFauxFactory.gen_numeric_string.to_i}, #{RFauxFactory.gen_boolean}]",
      },
      {
        :sc_type => 'hash',
        :value => "{{'#{RFauxFactory.gen_alpha}': '#{RFauxFactory.gen_alpha}'}}",
      },
      {
        :sc_type => 'yaml',
        :value => 'name=>XYZ',
      },
      {
        :sc_type => 'json',
        :value => '{"name": "XYZ"}',
      },
    ]
    lookup_key = lookup_keys(:five)
    valid_parameters_data.each do |data|
      lookup_key.parameter_type = data[:sc_type]
      lookup_key.default_value = data[:value]
      assert lookup_key.valid?, "Can't update lookup key with valid data #{data}"
    end
  end

  test "can create lookup key with long default_value" do
    as_user :one do
      lookup_key = FactoryBot.build(:puppetclass_lookup_key, :as_smart_class_param, :key_type => 'string',
                                    :override => true, :default_value => 'a' * 280, :puppetclass => puppetclasses(:one))
      assert_valid lookup_key
    end
  end
end
