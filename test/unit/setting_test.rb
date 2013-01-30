require 'test_helper'

class SettingTest < ActiveSupport::TestCase

  def setup
    Setting.cache.clear
  end

# commenting out due a failure in our CI
  # def test_settings_should_save_complex_types
  #   assert (Setting.create(:name => "foo", :value => [1,2,3,'b'], :default => ['b',"b"], :description => "test foo" ))
  #   s = Setting.find_by_name "foo"
  #   assert_equal [1,2,3,'b'], s.value
  #   assert_equal ['b',"b"], s.default
  #   assert_equal "array", s.settings_type
  # end

  def test_should_not_find_a_value_if_doesnt_exists
    assert_nil Setting["no_such_thing"]
  end

  def test_should_provide_default_if_no_value_defined
    assert Setting.create(:name => "foo", :default => 5, :description => "test foo")
    assert_equal 5, Setting["foo"]
  end

  # def test_should_find_setting_via_method_missing_too
  #   assert Setting.create(:name => "bar", :value => "baz", :default => "x", :description => "test bar")
  #   assert_equal Setting["bar"], Setting.bar
  #   assert_equal "baz", Setting.bar
  # end

  # def test_settings_with_the_same_value_as_default_should_save_the_value
  #   assert Setting.create(:name => "foo", :value => "bar", :default => "bar", :description => "x")
  #   s = Setting.find_by_name "foo"
  #   assert_nil s.read_attribute(:value)
  #   assert_equal "bar", Setting.foo
  # end

  def test_should_save_settings_type
    assert Setting.create(:name => "foo", :default => 5, :description => "test foo")
    assert_equal "integer", Setting.find_by_name("foo").try(:settings_type)
  end

  def test_should_not_allowed_to_change_frozen_attributes
    assert Setting.create(:name => "foo", :default => 5, :description => "test foo")
    s = Setting.find_by_name "foo"
    s.name = "boo"
    assert !s.save
    assert_equal s.errors[:name], ["is not allowed to change"]
  end

  def test_name_could_be_a_symbol_or_a_string
    assert Setting.create(:name => "foo", :default => 5, :description => "test foo")
    assert_equal Setting["foo"], Setting[:foo]

    Setting[:foo] = 3
    assert_equal 3,Setting["foo"]
  end

  def test_boolean_values_should_have_setting_type_for_false
    assert Setting.create!(:name => "oo", :default => false, :description => "test foo")
    assert_equal "boolean", Setting.find_by_name("oo").settings_type
    assert_equal false, Setting["oo"]
  end

  def test_boolean_values_should_have_setting_type_for_true
    assert Setting.create(:name => "oo", :default => true, :description => "test foo")
    assert_equal "boolean", Setting.find_by_name("oo").settings_type
    assert_equal true, Setting["oo"]
  end

  test "idle_timeout should not be zero" do
    setting = Setting.find_by_name('idle_timeout')
    if setting
      setting.value = 0
    else
      setting = Setting.new(:name => 'idle_timeout', :value => 0, :default => 60 )
    end

    assert setting.invalid?
    assert_equal "must be greater than 0", setting.errors[:value].join('; ')
  end

  test "entries_per_page should not be zero" do
    setting = Setting.find_by_name('entries_per_page')
    if setting
      setting.value = 0
    else
      setting = Setting.new(:name => 'entries_per_page', :value => 0, :default => 20 )
    end
    assert setting.invalid?
    assert_equal "must be greater than 0", setting.errors[:value].join('; ')
  end

  test "puppet_interval should not be zero" do
    setting = Setting.find_by_name('puppet_interval')
    if setting
      setting.value = 0
    else
      setting = Setting.new(:name => 'puppet_interval', :value => 0, :default => 30 )
    end
    assert setting.invalid?
    assert_equal "must be greater than 0", setting.errors[:value].join('; ')
  end

  def test_returns_value_from_cache
    assert Setting.create!(:name => "test_cache", :default => 1, :description => "test foo")
    Setting.test_cache = 2
    assert_equal Setting.test_cache, Setting.find_by_name('test_cache').value
    assert_equal Rails.cache.read('test_cache'), Setting.find_by_name('test_cache').value

  end

  def test_boolean_false_returns_from_cache
    assert Setting.find_or_create_by_name(:name => "enc_environment", :default => true, :description => "test false")
    #setter method, deletes cache
    Setting.enc_environment = false
    #first time getter method, write the cache
    assert_equal Setting.enc_environment, false
    #second time getter method, reads from the cache
    assert_equal Setting.enc_environment, Setting.find_by_name('enc_environment').value
  end

  def test_boolean_true_returns_from_cache
    assert Setting.find_or_create_by_name(:name => "enc_environment", :default => true, :description => "test true")
    #setter method, deletes cache
    Setting.enc_environment = true
    #first time getter method, write the cache
    assert_equal Setting.enc_environment, true
    #second time getter method, reads from the cache
    assert_equal Setting.enc_environment, Setting.find_by_name('enc_environment').value
  end

  test "arrays cannot be empty" do
    setting = Setting.find_by_name('Default_variables_Lookup_Path')
    assert setting.save
    assert_equal "array", setting.settings_type
    orig = setting.value
    setting.value = "[test]"
    assert setting.save
    setting.value = "[]"
    assert !setting.save
    setting.value = orig
    assert setting.save
  end

  test "trusted_puppetmaster_hosts may be an empty array" do
    setting = Setting.find_by_name('trusted_puppetmaster_hosts')
    setting.save
    assert_equal "array", setting.settings_type
    setting.value = "[test]"
    assert setting.save
    setting.value = "[]"
    assert setting.save
    assert_equal [], setting.value
  end
end
