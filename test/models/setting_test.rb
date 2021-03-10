require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_presence_of(:default)
  should validate_uniqueness_of(:name)
  should validate_inclusion_of(:settings_type).in_array(Setting::TYPES)

  def test_should_validate_inclusions
    assert Setting::URI_BLANK_ATTRS.include? "login_delegation_logout_url"
    assert Setting::IP_ATTRS.include? "libvirt_default_console_address"
  end

  def test_should_not_find_a_value_if_doesnt_exists
    assert_nil Setting["no_such_thing"]
  end

  setup do
    Setting::NOT_STRIPPED << 'not_stripped_test'
  end

  teardown do
    Setting::NOT_STRIPPED.delete 'not_stripped_test'
  end

  test 'should not strip setting value when parsing if we do not want to' do
    setting = Setting.create(:name => 'not_stripped_test', :value => 'whatever', :setting_type => 'string')
    trailing_space_val = 'Local '
    setting.parse_string_value(trailing_space_val)
    assert_equal setting.value, trailing_space_val
  end

  test "encrypted value is saved encrypted when created" do
    setting = Setting.create(:name => "foo", :value => 5, :default => 5, :description => "test foo", :encrypted => true)
    setting.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    setting.value = "123456"
    as_admin do
      assert setting.save
    end
    assert setting.read_attribute(:value).include? EncryptValue::ENCRYPTION_PREFIX
  end

  test "#value= with previously unencrypted value is encrypted when set" do
    setting = Setting.create(name: 'encrypted', value: 'first', default: 'test', description: 'Test', encrypted: false)
    setting.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    setting.encrypted = true
    setting.value = 'new'
    assert_difference 'setting.audits.count' do
      as_admin { setting.save! }
    end
    assert_includes setting.read_attribute(:value), EncryptValue::ENCRYPTION_PREFIX
    assert_equal 'new', setting.value
  end

  test "update an encrypted value should saved encrypted in db with audit, and decrypted while reading" do
    setting = settings(:encrypted)
    setting.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    setting.value = '123456'
    assert_difference 'setting.audits.count' do
      as_admin { assert setting.save }
    end
    assert setting.read_attribute(:value).include? EncryptValue::ENCRYPTION_PREFIX
    assert_equal '123456', setting.value
  end

  test "#value= with unchanged value on encrypted setting does not modify DB or create audit" do
    setting = Setting.create(name: 'encrypted', value: 'first', default: 'test', description: 'Test', encrypted: true)
    setting.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    setting.value = 'new'
    as_admin { setting.save! }
    db_value = setting.read_attribute(:value)
    assert_includes db_value, EncryptValue::ENCRYPTION_PREFIX
    assert_no_difference 'setting.audits.count' do
      setting.value = 'new'
      setting.save!
      assert_equal db_value, setting.read_attribute(:value)
    end
  end

  def test_should_provide_default_if_no_value_defined
    assert Setting.create(:name => "foo", :default => 5, :description => "test foo")
    assert_equal 5, Setting["foo"]
  end

  def test_settings_with_the_same_value_as_default_should_not_save_the_value
    assert Setting.create(:name => "foo", :value => "bar", :default => "bar", :description => "x")
    s = Setting.find_by_name "foo"
    assert_nil s.read_attribute(:value)
    assert_equal "bar", Setting[:foo]
  end

  def test_should_not_allow_to_change_frozen_attributes
    check_frozen_change :name, "new value"
    check_frozen_change :category, "Auth"
  end

  def test_name_could_be_a_symbol_or_a_string
    assert Setting.create(:name => "foo", :default => 5, :description => "test foo")
    assert_equal 5, Setting[:foo]
    assert_equal 5, Setting["foo"]
  end

  def test_should_save_value_on_assignment
    assert Setting.create(:name => "foo", :default => 5, :description => "test foo")

    Setting[:foo] = 3
    setting = Setting.find_by_name("foo")

    assert_equal 3, Setting["foo"]
    assert_equal 3, setting.value
  end

  def test_default_value_can_be_nil
    assert Setting.create(:name => "foo", :default => nil, :description => "test foo")
    assert_nil Setting["foo"]
  end

  def test_should_return_updated_value_only_after_it_is_saved
    setting = Setting.create(:name => "foo", :value => 5, :default => 5, :description => "test foo")

    setting.value = 3
    assert_equal 5, Setting["foo"]

    setting.save
    assert_equal 3, setting.value
  end

  def test_second_time_create_persists_only_default_value
    setting = Setting.create(:name => "foo", :value => 8, :default => 2, :description => "test foo")
    assert_equal 8, setting.value
    assert_equal 2, setting.default

    setting = Setting.create(:name => "foo", :value => 9, :default => 3, :description => "test foo")
    assert_equal 8, setting.value
    assert_equal 3, setting.default
  end

  def test_second_time_create_exclamation_persists_only_default_value
    setting = Setting.create!(:name => "foo", :value => 8, :default => 2, :description => "test foo")
    assert_equal 8, setting.value
    assert_equal 2, setting.default

    setting = Setting.create!(:name => "foo", :value => 9, :default => 3, :description => "test foo")
    assert_equal 8, setting.value
    assert_equal 3, setting.default
  end

  def test_create_exclamation_updates_description
    Setting.create!(:name => 'administrator', :description => 'Test', :default => 'root@localhost.com')
    s = Setting.find_by_name 'administrator'
    assert_equal 'Test', s.description
  end

  def test_create_with_missing_attrs_does_not_persist
    setting = Setting.create(:name => "foo")
    assert_equal false, setting.persisted?
  end

  def test_create_exclamation_with_missing_attrs_raises_exception
    assert_raises(ActiveRecord::RecordInvalid) do
      Setting.create!(:name => "foo")
    end
  end

  def test_set_method_prepares_attrs_for_creation
    options = Setting.set "test_attr", "some_description", "default_value", "full_name", "my_value"
    assert_equal "test_attr", options[:name]
    assert_equal "some_description", options[:description]
    assert_equal "default_value", options[:default]
    assert_equal "full_name", options[:full_name]
    assert_equal "my_value", options[:value]
  end

  def test_set_method_uses_values_from_args
    options = Setting.set "test_attr", "some_description", "default_value"
    refute options[:value]

    options = Setting.set "test_attr", "some_description", "default_value", "full_name", "my_value"
    assert_equal "my_value", options[:value]
  end

  def test_create_uses_values_from_SETTINGS
    SETTINGS[:test_attr] = "ape"
    options = Setting.create!(Setting.set("test_attr", "some_description", "default_value"))
    assert_equal "ape", options.value
  end

  def test_create_doesnt_change_value_if_absent_from_SETTINGS
    options = Setting.create!(Setting.set("unknown_attr", "some_description", "default_value"))
    assert_equal "default_value", options.value
  end

  def test_attributes_in_SETTINGS_are_readonly
    setting_name = "foo_#{rand(1000000)}"
    Setting.create!(:name => setting_name, :value => "bar", :default => "default", :description => "foo")
    SETTINGS[setting_name.to_sym] = "no-bar"

    persisted = Setting.find_by_name(setting_name)
    assert persisted.readonly?
  end

  def test_value_is_updated_after_change_in_SETTINGS
    setting_name = "foo_#{rand(1000000)}"
    Setting.create!(:name => setting_name, :value => "bar", :default => "default", :description => "foo")

    SETTINGS[setting_name.to_sym] = "no-bar"

    persisted = Setting.create!(:name => setting_name, :description => "foo", :default => "default")
    assert_equal "no-bar", persisted.value
  ensure
    SETTINGS.delete(setting_name.to_sym)
  end

  def test_first_or_create_works
    assert_nothing_raised do
      name = "rand_#{rand(1_000_000)}"
      setting = Setting.where(:name => name).first_or_create
      assert_equal name, setting.name
    end
  end

  # tests for saving settings attributes
  def test_settings_should_save_arrays
    check_properties_saved_and_loaded_ok :name => "foo", :value => [1, 2, 3, 'b'], :default => ['b', "b"], :description => "test foo"
  end

  def test_settings_should_save_hashes
    check_properties_saved_and_loaded_ok :name => "foo", :value => {"a" => "A"}, :default => {"b" => "B"}, :description => "test foo"
  end

  def test_settings_should_save_booleans
    check_properties_saved_and_loaded_ok :name => "foo", :value => true, :default => false, :description => "test foo"
  end

  def test_settings_should_save_integers
    check_properties_saved_and_loaded_ok :name => "foo", :value => 32, :default => 83, :description => "test foo"
  end

  def test_settings_should_save_strings
    check_properties_saved_and_loaded_ok :name => "foo", :value => "  value  ", :default => "default", :description => "test foo"
  end

  # tests for choosing correct type
  def test_should_autoselect_correct_type_for_integer_value
    check_correct_type_for "integer", 5
  end

  def test_should_autoselect_correct_type_for_array_value
    check_correct_type_for "array", [1, 2, 3]
  end

  def test_should_autoselect_correct_type_for_hash_value
    check_correct_type_for "hash", {"a" => "A"}
  end

  def test_should_autoselect_correct_type_for_string_value
    check_correct_type_for "string", "some value"
  end

  def test_should_autoselect_correct_type_for_boolean_value
    check_correct_type_for "boolean", true
    check_correct_type_for "boolean", false
  end

  # tests for caching
  def test_returns_value_from_cache
    check_value_returns_from_cache_with :name => "test_cache", :default => 1, :value => 2, :description => "test foo"
  end

  def test_boolean_false_returns_from_cache
    check_value_returns_from_cache_with :name => "test_cache", :default => true, :value => false, :description => "test foo"
  end

  def test_boolean_true_returns_from_cache
    check_value_returns_from_cache_with :name => "test_cache", :default => true, :value => true, :description => "test foo"
  end

  # tests for default type constraints
  test "arrays cannot be empty by default" do
    check_setting_did_not_save_with :name => "foo", :value => [], :default => ["a", "b", "c"], :description => "test foo"
  end

  test "hashes can be empty by default" do
    check_properties_saved_and_loaded_ok :name => "foo", :value => {}, :default => {"a" => "A"}, :description => "test foo"
  end

  test "integer attributes can be zero by default" do
    check_properties_saved_and_loaded_ok :name => "foo83", :value => 0, :default => 0, :description => "test foo"
  end

  # test particular settings
  test "idle_timeout should not be zero" do
    check_zero_value_not_allowed_for 'idle_timeout'
  end

  test "entries_per_page should not be zero" do
    check_zero_value_not_allowed_for 'entries_per_page'
  end

  test "puppet_interval should not be zero" do
    check_zero_value_not_allowed_for 'puppet_interval'
  end

  test "trusted_hosts can be empty array" do
    check_empty_array_allowed_for "trusted_hosts"
  end

  test "trusted_hosts must have comma separated values" do
    attrs = { :name => "trusted_hosts", :default => [], :description => "desc" }
    assert Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting = Setting.find_by_name("trusted_hosts")
    setting.value = ["localhost", "remotehost"]
    assert setting.save
    setting.value = ["localhost remotehost"]
    refute setting.save
    assert_equal "must be comma separated", setting.errors[:value].first
  end

  test "foreman_url must have valid formant" do
    attrs = { :name => "foreman_url", :default => "http://foo.com" }
    assert Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting = Setting.find_by_name("foreman_url")
    setting.value = "##"
    assert !setting.save
    assert_equal "URL must be valid and schema must be one of http and https", setting.errors[:value].first
  end

  test "foreman_url must have proper format" do
    attrs = { :name => "foreman_url", :default => "http://foo.com" }
    assert Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting = Setting.find_by_name("foreman_url")
    setting.value = "random_string"
    assert !setting.save
    assert_equal "URL must be valid and schema must be one of http and https", setting.errors[:value].first
  end

  test "foreman_url cannot be blank" do
    attrs = { :name => "foreman_url", :default => "http://foo.com" }
    setting = Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting.value = ""
    assert !setting.save
    assert_equal "URL must be valid and schema must be one of http and https", setting.errors[:value].first
  end

  test "unattended_url must have a valid format" do
    attrs = { :name => "unattended_url", :default => "http://foo.com" }
    assert Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting = Setting.find_by_name("unattended_url")
    setting.value = "##"
    assert !setting.save
    assert_equal "URL must be valid and schema must be one of http and https", setting.errors[:value].first
  end

  test "unattended_url must have proper format" do
    attrs = { :name => "foreman_url", :default => "http://foo.com" }
    assert Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting = Setting.find_by_name("foreman_url")
    setting.value = "random_string"
    assert !setting.save
    assert_equal "URL must be valid and schema must be one of http and https", setting.errors[:value].first
  end

  test "login_delegation_logout_url must have proper format or be blank" do
    attrs = { :name => "login_delegation_logout_url", :default => nil, :description => "desc" }
    assert Setting.create!(attrs)
    setting = Setting.find_by_name("login_delegation_logout_url")
    setting.value = "http://somepage.org"
    assert setting.save
    setting.value = nil
    assert setting.save
    setting.value = "random value"
    refute setting.save
    assert_equal "URL must be valid and schema must be one of http and https", setting.errors[:value].first
  end

  test "libvirt_default_console_address must have proper IP format" do
    attrs = { :name => "libvirt_default_console_address", :default => "127.0.0.1", :description => "desc" }
    assert Setting.create!(attrs)
    setting = Setting.find_by_name("libvirt_default_console_address")
    setting.value = "192.168.100.122"
    assert setting.save
    setting.value = "396.158.147.569"
    refute setting.save
    assert_equal "is invalid", setting.errors[:value].first
  end

  test "integers in setting cannot be more then 8 characters" do
    check_length_must_be_under_8 'entries_per_page'
  end

  # test parsing string values
  test "parse boolean attribute from string" do
    check_parsed_value "boolean", true, "true"
    check_parsed_value "boolean", false, "false"
    check_parsed_value "boolean", true, "True"
    check_parsed_value "boolean", false, "False"
    check_parsed_value "boolean", true, "1"
    check_parsed_value "boolean", false, "0"
    check_parsed_value_failure "boolean", "unknown"
  end

  test "parse integer attribute from string" do
    check_parsed_value "integer", 8, 8
    check_parsed_value "integer", 8, "8"
    check_parsed_value_failure "integer", "unknown"
  end

  test "parse array attribute from string" do
    check_parsed_value "array", [], "[]"
    check_parsed_value "array", ["a", "b"], "[a,b]"
    check_parsed_value "array", ["a", "b"], "[ a, b ]"
    check_parsed_value "array", [1, 2], "[1, 2]"
    check_parsed_value_failure "array", "1234"
  end

  test "parse string attribute from string" do
    check_parsed_value "string", "ahoy", "ahoy"
    check_parsed_value "string", "ahoy", " ahoy "
    check_parsed_value "string", "123", "123"
  end

  test "parse hash attribute raises exception without settings_type" do
    setting = Setting.new(:name => "foo", :default => "default", :settings_type => "hash")
    assert_raises(Foreman::Exception) do
      setting.parse_string_value("some_value")
    end
  end

  test "parse attribute without settings_type defaults to string" do
    setting = Setting.new(:name => "foo", :default => "default")
    setting.parse_string_value(12345)
    setting.save
    assert_equal "string", setting.settings_type
    assert_equal "12345", setting.value
  end

  test "parse attribute raises exception for undefined types" do
    class CustomSetting < Setting
      TYPES << "custom_type"
    end

    setting = CustomSetting.new(:name => "foo", :default => "default", :settings_type => "custom_type")
    assert_raises(Foreman::Exception) do
      setting.parse_string_value("some_value")
    end
  end

  test "create! can update category" do
    s = Setting.create!(:name => "foo", :value => "bar", :category => "Setting::General", :default => "bar", :description => "baz")
    assert_equal s.category, "Setting::General"
    s = Setting.create!(:name => "foo", :category => "Setting::Auth")
    assert_equal s.category, "Setting::Auth"
  end

  test "create succeeds when cache is non-functional" do
    Setting.cache.expects(:delete).with(Setting.cache_key('test_broken_cache')).returns(false)
    assert_valid Setting.create!(:name => 'test_broken_cache', :description => 'foo', :default => 'default')
  end

  test '.expand_wildcard_string wraps the regexp with \A and \Z' do
    assert Setting.regexp_expand_wildcard_string('a').start_with? '\A'
    assert Setting.regexp_expand_wildcard_string('a').end_with? '\Z'
  end

  test '.regexp_expand_wildcard_string converts all * to .*' do
    assert_equal '\A.*a.*\Z', Setting.regexp_expand_wildcard_string('*a*')
  end

  test '.regexp_expand_wildcard_string escape other regexp characters, e.g. dot' do
    assert_equal '\A.*\..*\Z', Setting.regexp_expand_wildcard_string('*.*')
  end

  test '.convert_array_to_regexp joins all strings with pipe and makes it regexp' do
    assert_equal /\Aa.*\Z|\Ab.*\Z/, Setting.convert_array_to_regexp(['a*', 'b*'])
  end

  test "host's owner should be valid" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Setting[:host_owner] = "xyz"
    end
  end

  private

  def check_parsed_value(settings_type, expected_value, string_value)
    setting = Setting.new(:name => "foo", :default => "default", :settings_type => settings_type)
    setting.parse_string_value(string_value)

    assert_equal expected_value, setting.value
  end

  def check_parsed_value_failure(settings_type, string_value)
    setting = Setting.new(:name => "foo", :default => "default", :settings_type => settings_type)
    setting.parse_string_value(string_value)

    assert_equal "default", setting.value
    assert setting.errors[:value].join(";").include?("is invalid")
  end

  def check_frozen_change(attr_name, value)
    attrs = { :name => "foo", :default => 5, :description => "test foo" }
    assert Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting = Setting.find_by_name("foo")

    setting.send("#{attr_name}=", value)
    assert !setting.save, "Setting allowed to save new value for frozen attribute '#{attr_name}'"
    assert setting.errors[attr_name].join(";").include?("is not allowed to change")
  end

  def check_zero_value_not_allowed_for(setting_name)
    attrs = { :name => setting_name, :value => 0, :default => 30 }
    setting = Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting.value = 0

    refute_valid setting, :value, "must be greater than 0"

    setting.value = 1
    assert_valid setting
  end

  def check_length_must_be_under_8(setting_name)
    attrs = { :name => setting_name, :default => 30 }
    setting = Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting.value = 123456789

    refute_valid setting, :value, /is too long \(maximum is 8 characters\)/

    setting.value = 12
    assert_valid setting
  end

  def check_empty_array_allowed_for(setting_name)
    attrs = { :name => setting_name, :value => [], :default => [] }
    setting = Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting.value = []
    assert_valid setting

    setting.value = [1]
    assert_valid setting
  end

  def check_correct_type_for(type, value)
    assert Setting.create(:name => "foo", :default => value, :description => "test foo")
    assert_equal type, Setting.find_by_name("foo").try(:settings_type)
  end

  def check_properties_saved_and_loaded_ok(options = {})
    assert Setting.where(:name => options[:name]).first || Setting.create(options)
    s = Setting.find_by_name options[:name]
    assert_equal options[:value], s.value
    assert_equal options[:default], s.default
  end

  def check_setting_did_not_save_with(options = {})
    setting = Setting.new(options)
    assert !setting.save
  end

  def check_value_returns_from_cache_with(options = {})
    name = options[:name]
    cache_key = Setting.cache_key(name)

    # cache must be cleared on create
    Rails.cache.write(cache_key, "old value")
    assert Setting.create(options)
    assert_nil Rails.cache.read(cache_key)

    # first time getter method, write the cache
    Rails.cache.delete(cache_key)
    assert_equal options[:value], Setting[name]
    assert_equal options[:value], Rails.cache.read(cache_key)

    # setter method deletes the cache
    Setting[name] = options[:value]
    assert_nil Rails.cache.read(cache_key)
  end

  test 'bmc_credentials_accessible may not be disabled with safemode_render disabled' do
    Setting[:safemode_render] = false
    bmc = Setting.find_by_name('bmc_credentials_accessible')
    bmc.value = false
    refute_valid bmc, :base, 'Unable to disable bmc_credentials_accessible when safemode_render is disabled'
  end

  test 'safemode_render may not be disabled with bmc_credentials_accessible disabled' do
    Setting[:bmc_credentials_accessible] = false
    bmc = Setting.find_by_name('safemode_render')
    bmc.value = false
    refute_valid bmc, :base, 'Unable to disable safemode_render when bmc_credentials_accessible is disabled'
  end

  def sticky_setting
    'Setting::General'
  end

  test 'stick_general_first: should unshift all settings of sticky category to the beginning of list' do
    sorted_list = Setting.stick_general_first
    assert_equal sticky_setting, sorted_list.keys.first
  end

  test 'stick_general_first: should work even if general category settings does not exists' do
    sorted_list = Setting.where.not(:category => sticky_setting).stick_general_first
    refute_empty sorted_list
    assert sorted_list.keys.exclude?(sticky_setting)
  end

  test 'orders settings alphabetically' do
    a_name = 'a_foo'
    b_name = 'b_foo'
    c_name = 'c_foo'
    FactoryBot.create(:setting, :name => b_name, :default => 'whatever', :value => 'whatever',  :full_name => 'B Foo Name')
    FactoryBot.create(:setting, :name => a_name, :default => 'whatever', :value => 'whatever',  :full_name => 'A Foo Name')
    FactoryBot.create(:setting, :name => c_name, :default => 'whatever', :value => 'whatever',  :full_name => 'C Foo Name')
    settings = Setting.live_descendants.select(&:full_name)
    a_foo = settings.index { |item| item.name == a_name }
    b_foo = settings.index { |item| item.name == b_name }
    c_foo = settings.index { |item| item.name == c_name }
    assert a_foo
    assert b_foo
    assert c_foo
    assert a_foo < b_foo
    assert b_foo < c_foo
  end

  test "should update login page footer text with multiple valid long values" do
    setting = Setting.find_by_name("login_text")
    RFauxFactory.gen_strings(1000).values.each do |value|
      setting.value = value
      assert setting.valid?, "Can't update discovery_prefix setting with valid value #{value}"
    end
  end
end
