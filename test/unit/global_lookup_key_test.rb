require 'test_helper'

class GlobalLookupKeyTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end
  test "name can't be blank" do
    parameter = GlobalLookupKey.new :key => "  ", :default_value => "some_value", :should_be_global => true
    assert parameter.key.strip.empty?
    assert !parameter.save
  end

  test "name can't contain white spaces" do
    parameter = GlobalLookupKey.new :key => "   a new     param    ", :default_value => "some_value", :should_be_global => true
    assert !parameter.save

    parameter.key.gsub!(/\s+/,'_')
    assert parameter.save
  end

  test "value can be blank" do
    parameter = GlobalLookupKey.new :key => "some_parameter", :default_value => "   ", :should_be_global => true
    assert parameter.default_value.strip.empty?
    assert parameter.save
  end

  test "value can be empty" do
    parameter = GlobalLookupKey.new :key => "some_parameter", :default_value => "", :should_be_global => true
    assert parameter.default_value.strip.empty?
    assert parameter.save
  end

  test "value can contain spaces and unusual characters" do
    parameter = GlobalLookupKey.new :key => "some_parameter", :default_value => "   some crazy \"\'&<*%# value", :should_be_global => true
    assert parameter.save

    assert_equal "   some crazy \"\'&<*%# value", parameter.default_value
  end

  test "duplicate keys cannot exist" do
    GlobalLookupKey.create :key => "some_parameter", :default_value => "value", :should_be_global => true
    parameter2 = GlobalLookupKey.create :key => "some_parameter", :default_value => "value", :should_be_global => true
    assert !parameter2.valid?
    assert  parameter2.errors.full_messages[0] == "Key has already been taken"
  end

  test "duplicate matches cannot exist" do
    domain = Domain.where(:name => "domain").first_or_create
    parameter = GlobalLookupKey.create(:key => "value")
    LookupValue.create(:lookup_key_id => parameter.id, :value => "value", :match => domain.lookup_value_match)
    value = LookupValue.create(:lookup_key_id => parameter.id, :value => "value2", :match => domain.lookup_value_match)
    refute value.valid?
  end

  test "should have a matcher" do
    setup_user "create"
    domain = Domain.where(:name => "domain").first_or_create
    parameter = GlobalLookupKey.create(:key => "value")
    value = LookupValue.new(:lookup_key_id => parameter.id, :value => "value")
    refute value.valid?
    value.match = domain.lookup_value_match
    assert value.save
  end

  test "when removing the last override of a key when should_be_global is false the lookup_key should be deleted " do
    domain = Domain.where(:name => "domain").first_or_create
    parameter = GlobalLookupKey.create(:key => "value", :should_be_global => false)
    value = LookupValue.create(:lookup_key_id => parameter.id, :value => "value", :match => domain.lookup_value_match)
    assert GlobalLookupKey.where(:key => "value").present?
    value.destroy
    refute GlobalLookupKey.where(:key => "value").present?
  end

  test "when removing the last override of a key when should_be_global is true the lookup_key should not be deleted " do
    domain = Domain.where(:name => "domain").first_or_create
    parameter = GlobalLookupKey.create(:key => "value", :should_be_global => true)
    value = LookupValue.create(:lookup_key_id => parameter.id, :value => "value", :match => domain.lookup_value_match)
    assert GlobalLookupKey.where(:key => "value").present?
    value.destroy
    assert GlobalLookupKey.where(:key => "value").present?
  end
end
