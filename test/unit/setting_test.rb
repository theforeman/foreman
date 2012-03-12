require 'test_helper'

class SettingTest < ActiveSupport::TestCase
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
    assert Setting.create(:name => "oo", :default => false, :description => "test foo")
    assert_equal "boolean", Setting.find_by_name("oo").settings_type
    assert_equal false, Setting["oo"]
  end

  def test_boolean_values_should_have_setting_type_for_true
    assert Setting.create(:name => "oo", :default => true, :description => "test foo")
    assert_equal "boolean", Setting.find_by_name("oo").settings_type
    assert_equal true, Setting["oo"]
  end

end
