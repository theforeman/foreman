require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)

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
    setting = Setting.create(:name => 'not_stripped_test', :value => 'whatever')
    trailing_space_val = 'Local '
    setting.parse_string_value(trailing_space_val)
    assert_equal setting.value, trailing_space_val
  end

  test "encrypted value is saved encrypted when created" do
    Setting.any_instance.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    setting = Foreman.settings.set_user_value('root_pass', '12345678')
    as_admin do
      assert setting.save
    end
    assert setting.read_attribute(:value).include? EncryptValue::ENCRYPTION_PREFIX
  end

  test "#value= with previously unencrypted value is encrypted when set" do
    Setting['foreman_url'] = 'http://unencrypted-foreman.example.net'
    Setting.any_instance.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    Foreman.settings.find('foreman_url').encrypted = true
    setting = Foreman.settings.set_user_value('foreman_url', 'http://new.example.net')
    assert_difference 'setting.audits.count' do
      as_admin { setting.save! }
    end
    assert_includes setting.read_attribute(:value), EncryptValue::ENCRYPTION_PREFIX
    assert_equal 'http://new.example.net', setting.value
  end

  test "update an encrypted value should saved encrypted in db with audit, and decrypted while reading" do
    Setting['foreman_url'] = 'http://unencrypted-foreman.example.net'
    Setting.any_instance.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    Foreman.settings.find('foreman_url').encrypted = true
    setting = Foreman.settings.set_user_value('foreman_url', 'http://new.example.net')
    assert_difference 'setting.audits.count' do
      as_admin { assert setting.save }
    end
    assert setting.read_attribute(:value).include? EncryptValue::ENCRYPTION_PREFIX
    assert_equal 'http://new.example.net', setting.value
  end

  test "#value= with unchanged value on encrypted setting does not modify DB or create audit" do
    Setting.any_instance.expects(:encryption_key).at_least_once.returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    Setting['root_pass'] = 'somepass'
    setting = Setting.find_by(name: 'root_pass')
    db_value = setting.read_attribute(:value)
    assert_includes db_value, EncryptValue::ENCRYPTION_PREFIX
    assert_no_difference 'setting.audits.count' do
      setting.value = 'somepass'
      setting.save!
    end
    assert_equal db_value, setting.read_attribute(:value)
  end

  test "root_pass should be at least 8 characters long" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Setting[:root_pass] = "1234567"
    end
  end

  test 'proxy the value get to the registry' do
    SettingRegistry.instance.expects(:[]).with('foo')
    Setting['foo']
  end

  def test_settings_with_the_same_value_as_default_should_not_save_the_value
    setting = Setting.new(name: "foo", value: "bar")
    setting.stubs(default: 'bar')
    assert setting.save
    s = Setting.find_by_name 'foo'
    assert_nil s.read_attribute(:value)
  end

  def test_should_not_allow_to_change_frozen_attributes
    check_frozen_change :name, "new value"
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

  def test_first_or_create_works
    assert_nothing_raised do
      name = "rand_#{rand(1_000_000)}"
      setting = Setting.where(:name => name).first_or_create
      assert_equal name, setting.name
    end
  end

  # tests for saving settings attributes
  def test_settings_should_save_arrays
    check_properties_saved_and_loaded_ok :name => "foo", :value => [1, 2, 3, 'b']
  end

  def test_settings_should_save_hashes
    check_properties_saved_and_loaded_ok :name => "foo", :value => {"a" => "A"}
  end

  def test_settings_should_save_booleans
    check_properties_saved_and_loaded_ok :name => "foo", :value => true
  end

  def test_settings_should_save_integers
    check_properties_saved_and_loaded_ok :name => "foo", :value => 32
  end

  def test_settings_should_save_strings
    check_properties_saved_and_loaded_ok :name => "foo", :value => "  value  "
  end

  test "hashes can be empty by default" do
    check_properties_saved_and_loaded_ok :name => "foo", :value => {}
  end

  test "integer attributes can be zero by default" do
    check_properties_saved_and_loaded_ok :name => "foo83", :value => 0
  end

  # test particular settings
  test "idle_timeout should not be zero" do
    check_zero_value_not_allowed_for 'idle_timeout'
  end

  test "entries_per_page should not be zero" do
    check_zero_value_not_allowed_for 'entries_per_page'
  end

  test "trusted_hosts can be empty array" do
    check_empty_array_allowed_for "trusted_hosts"
  end

  test "trusted_hosts must have comma separated values" do
    assert Setting.create(name: 'trusted_hosts', value: [])
    setting = Setting.find_by_name("trusted_hosts")
    setting.value = ["localhost", "remotehost"]
    assert setting.save
    setting.value = ["localhost remotehost"]
    refute setting.save
    assert_equal "must be comma separated", setting.errors[:value].first
  end

  test "foreman_url must have valid formant" do
    assert Setting.create(name: 'foreman_url', value: 'http://test.example.org')
    setting = Setting.find_by_name("foreman_url")
    setting.value = "##"
    assert !setting.save
    assert_equal "URL must be valid and schema must be one of http and https", setting.errors[:value].first
  end

  test "foreman_url must have proper format" do
    assert Setting.create(name: 'foreman_url', value: 'http://test.example.org')
    setting = Setting.find_by_name("foreman_url")
    setting.value = "random_string"
    assert !setting.save
    assert_equal "URL must be valid and schema must be one of http and https", setting.errors[:value].first
  end

  test "foreman_url cannot be blank" do
    setting = Setting.create(name: 'foreman_url', value: 'http://test.example.org')
    setting.value = ""
    assert !setting.save
    assert_equal "URL must be valid and schema must be one of http and https", setting.errors[:value].first
  end

  test "unattended_url must have a valid format" do
    assert Setting.create(name: 'unattended_url', value: 'http://test.example.org')
    setting = Setting.find_by_name('unattended_url')
    setting.value = "##"
    assert !setting.save
    assert_equal "URL must be valid and schema must be one of http and https", setting.errors[:value].first
  end

  test "unattended_url must have proper format" do
    assert Setting.create(name: 'foreman_url', value: 'http://test.example.org')
    setting = Setting.find_by_name("foreman_url")
    setting.value = "random_string"
    assert !setting.save
    assert_equal "URL must be valid and schema must be one of http and https", setting.errors[:value].first
  end

  test "login_delegation_logout_url must have proper format or be blank" do
    assert Setting.create!(name: "login_delegation_logout_url")
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
    attrs = { name: "libvirt_default_console_address", value: '192.168.1.1' }
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

  test 'convert_array_to_regexp supports ? ' do
    assert_equal true, Setting.convert_array_to_regexp(['on?????????????.*']).match?('on86bb6c1f143a4.3111')
  end

  test "host's owner should be valid" do
    assert_raises(ActiveRecord::RecordInvalid) do
      Setting[:host_owner] = "xyz"
    end
  end

  private

  def check_parsed_value(settings_type, expected_value, string_value)
    setting = Setting.new(:name => "foo")
    setting.stubs(settings_type: settings_type)
    setting.parse_string_value(string_value)

    assert_equal expected_value, setting.value
  end

  def check_parsed_value_failure(settings_type, string_value)
    setting = Setting.new(name: "foo")
    setting.stubs(settings_type: settings_type)
    assert_raises Foreman::SettingValueException do
      setting.parse_string_value(string_value)
    end

    assert_nil setting.value
    assert setting.errors[:value].join(";").include?("is invalid")
  end

  def check_frozen_change(attr_name, value)
    attrs = { :name => "foo" }
    assert Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting = Setting.find_by_name("foo")

    setting.send("#{attr_name}=", value)
    assert !setting.save, "Setting allowed to save new value for frozen attribute '#{attr_name}'"
    assert setting.errors[attr_name].join(";").include?("is not allowed to change")
  end

  def check_zero_value_not_allowed_for(setting_name)
    attrs = { :name => setting_name, :value => 0 }
    setting = Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting.value = 0

    refute_valid setting, :value, "must be greater than 0"

    setting.value = 1
    assert_valid setting
  end

  def check_length_must_be_under_8(setting_name)
    attrs = { :name => setting_name }
    setting = Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting.value = 123456789

    refute_valid setting, :value, /is too long \(maximum is 8 characters\)/

    setting.value = 12
    assert_valid setting
  end

  def check_empty_array_allowed_for(setting_name)
    attrs = { :name => setting_name, :value => [] }
    setting = Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    setting.value = []
    assert_valid setting

    setting.value = [1]
    assert_valid setting
  end

  def check_properties_saved_and_loaded_ok(options = {})
    assert Setting.where(:name => options[:name]).first || Setting.create(options)
    s = Setting.find_by_name options[:name]
    assert_equal options[:value], s.value
  end

  def check_setting_did_not_save_with(options = {})
    setting = Setting.new(options)
    assert !setting.save
  end

  test 'orders settings alphabetically' do
    a_name = 'a_foo'
    b_name = 'b_foo'
    c_name = 'c_foo'
    FactoryBot.create(:setting, :name => b_name, :value => 'whatever')
    FactoryBot.create(:setting, :name => a_name, :value => 'whatever')
    FactoryBot.create(:setting, :name => c_name, :value => 'whatever')
    settings = Setting.live_descendants.select(&:name)
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
    setting = Setting.create(name: 'login_text')
    RFauxFactory.gen_strings(1000).values.each do |value|
      setting.value = value
      assert setting.valid?, "Can't update discovery_prefix setting with valid value #{value}"
    end
  end
end
