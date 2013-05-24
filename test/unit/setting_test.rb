require 'test_helper'

class SettingTest < ActiveSupport::TestCase

  def setup
    Setting.cache.clear
  end

  def test_should_not_find_a_value_if_doesnt_exists
    assert_nil Setting["no_such_thing"]
  end

  def test_should_provide_default_if_no_value_defined
    assert Setting.create(:name => "foo", :default => 5, :description => "test foo")
    assert_equal 5, Setting["foo"]
  end

  def test_should_find_setting_via_method_missing_too
    assert Setting.create(:name => "bar", :value => "baz", :default => "x", :description => "test bar")
    assert_equal Setting["bar"], Setting.bar
    assert_equal "baz", Setting.bar
  end

  def test_settings_with_the_same_value_as_default_should_not_save_the_value
    assert Setting.create(:name => "foo", :value => "bar", :default => "bar", :description => "x")
    s = Setting.find_by_name "foo"
    assert_nil s.read_attribute(:value)
    assert_equal "bar", Setting.foo
  end

  def test_should_not_allow_to_change_frozen_attributes
    check_frozen_change :name, "new value"
    check_frozen_change :default, "new value"
    check_frozen_change :description, "new value"
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
    assert_equal nil, Setting["foo"]
  end

  def test_should_return_updated_value_only_after_it_gets_presistent
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

  def test_create_with_missing_attrs_does_not_persist
    setting = Setting.create(:name => "foo")
    assert_equal false, setting.persisted?
  end

  def test_create_exclamation_with_missing_attrs_raises_exception
    assert_raises(ActiveRecord::RecordInvalid) do
      setting = Setting.create!(:name => "foo")
    end
  end

  def test_set_method_prepares_attrs_for_creation
    options = Setting.set "test_attr", "some_description", "default_value", "my_value"
    assert_equal "test_attr", options[:name]
    assert_equal "some_description", options[:description]
    assert_equal "default_value", options[:default]
    assert_equal "my_value", options[:value]
  end

  def test_set_method_uses_values_from_SETTINGS
    SETTINGS[:test_attr] = "ape"
    options = Setting.set "test_attr", "some_description", "default_value"
    assert_equal "ape", options[:value]

    options = Setting.set "test_attr", "some_description", "default_value", "my_value"
    assert_equal "my_value", options[:value]
  end


  # tests for saving settings attributes
  def test_settings_should_save_arrays
    check_properties_saved_and_loaded_ok :name => "foo", :value => [1,2,3,'b'], :default => ['b',"b"], :description => "test foo"
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

  test "trusted_puppetmaster_hosts can be empty array" do
    check_empty_array_allowed_for "trusted_puppetmaster_hosts"
  end


  # test parsing string values
  test "parse boolean attribute from string" do
    check_parsed_value "boolean", true, "true"
    check_parsed_value "boolean", false, "false"
    check_parsed_value "boolean", true, "True"
    check_parsed_value "boolean", false, "False"
    check_parsed_value_failure "boolean", "1"
    check_parsed_value_failure "boolean", "0"
    check_parsed_value_failure "boolean", "unknown"
  end

  test "parse integer attribute from string" do
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

  private

  def check_parsed_value settings_type, expected_value, string_value
    setting = Setting.new(:name => "foo", :default => "default", :settings_type => settings_type)
    setting.parse_string_value(string_value)

    assert_equal expected_value, setting.value
  end

  def check_parsed_value_failure settings_type, string_value
    setting = Setting.new(:name => "foo", :default => "default", :settings_type => settings_type)
    setting.parse_string_value(string_value)

    assert_equal "default", setting.value
    assert setting.errors[:value].join(";").include?("invalid value")
  end

  def check_frozen_change attr_name, value
    assert Setting.find_or_create_by_name(:name => "foo", :default => 5, :description => "test foo")
    setting = Setting.find_by_name("foo")

    setting.send("#{attr_name}=", value)
    assert !setting.save, "Setting allowed to save new value for frozen attribute '#{attr_name}'"
    assert setting.errors[attr_name].join(";").include?("is not allowed to change")
  end

  def check_zero_value_not_allowed_for setting_name
    setting = Setting.find_or_create_by_name(setting_name, :value => 0, :default => 30)
    setting.value = 0

    assert setting.invalid?
    assert setting.errors[:value].join(";").include?("must be greater than 0")

    setting.value = 1
    assert !setting.invalid?
  end

  def check_empty_array_allowed_for setting_name
    setting = Setting.find_or_create_by_name(setting_name, :value => [], :default => [])
    setting.value = []
    assert !setting.invalid?

    setting.value = [1]
    assert !setting.invalid?
  end

  def check_correct_type_for type, value
    assert Setting.create(:name => "foo", :default => value, :description => "test foo")
    assert_equal type, Setting.find_by_name("foo").try(:settings_type)
  end

  def check_properties_saved_and_loaded_ok options={}
    assert Setting.find_or_create_by_name(options)
    s = Setting.find_by_name options[:name]
    assert_equal options[:value], s.value
    assert_equal options[:default], s.default
  end

  def check_setting_did_not_save_with options={}
     setting = Setting.new(options)
     assert !setting.save
  end

  def check_value_returns_from_cache_with options={}
    name = options[:name].to_s

    #cache must be cleared on create
    Rails.cache.write(name, "old value")
    assert Setting.create(options)
    assert_nil Rails.cache.read(name)

    #first time getter method, write the cache
    Rails.cache.delete(name)
    assert_equal options[:value], Setting[name]
    assert_equal options[:value], Rails.cache.read(name)

    #setter method deletes the cache
    Setting[name] = options[:value]
    assert_nil Rails.cache.read(name)
  end

end
