require 'test_helper'

class PuppetclassLookupKeyTest < ActiveSupport::TestCase
  test "should not update default value unless override is true" do
    lookup_key = FactoryGirl.create(:puppetclass_lookup_key,
                                    :default_value => "test123")
    refute lookup_key.override
    lookup_key.default_value = '33333'
    refute lookup_key.valid?
  end

  test "should update description when override is false" do
    lookup_key = FactoryGirl.create(:puppetclass_lookup_key, :key_type => 'string',
                                    :default_value => "test123", :description => 'description')
    refute lookup_key.override
    lookup_key.description = 'new_description'
    assert lookup_key.valid?
  end

  test "should save without changes when override is false" do
    lookup_key = FactoryGirl.create(:puppetclass_lookup_key, :key_type => 'string',
                                    :default_value => "test123", :description => 'description')
    refute lookup_key.override
    assert lookup_key.valid?
  end

  test "should allow to uncheck override" do
    lookup_key = FactoryGirl.create(:puppetclass_lookup_key, :key_type => 'string',
                                    :default_value => "test123", :override => true)

    lookup_key.override = false
    assert lookup_key.valid?
  end
end
