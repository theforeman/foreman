require 'test_helper'

class PuppetclassLookupKeyTest < ActiveSupport::TestCase
  test "should not update default value unless override is true" do
    lookup_key = FactoryGirl.create(:puppetclass_lookup_key,
                                    :default_attributes => {:value => "test123"})
    refute lookup_key.override
    lookup_key.default.value = '33333'
    refute lookup_key.valid?
  end

  test "should update description when override is false" do
    lookup_key = FactoryGirl.create(:puppetclass_lookup_key, :key_type => 'string',
                                    :default_attributes => {:value => "test123"}, :description => 'description')
    refute lookup_key.override
    lookup_key.description = 'new_description'
    assert lookup_key.valid?
  end

  test "should save without changes when override is false" do
    lookup_key = FactoryGirl.create(:puppetclass_lookup_key, :key_type => 'string',
                                    :default_attributes => {:value => "test123"}, :description => 'description')
    refute lookup_key.override
    assert lookup_key.valid?
  end

  test "should allow to uncheck override" do
    lookup_key = FactoryGirl.create(:puppetclass_lookup_key, :key_type => 'string',
                                    :default_attributes => {:value => "test123"}, :override => true)

    lookup_key.override = false
    assert lookup_key.valid?
  end

  context "delete params with class" do
    setup do
      @env1 = FactoryGirl.create(:environment)
      @puppetclass = FactoryGirl.create(:puppetclass)
      @lookup_key = FactoryGirl.create(:puppetclass_lookup_key, :key_type => 'string',
                                      :default_attributes => {:value => "test123"}, :override => true)
      FactoryGirl.create(:environment_class, :puppetclass => @puppetclass, :environment => @env1, :puppetclass_lookup_key => @lookup_key)
    end

    test "deleting puppetclass should delete smart class parameters" do
      env2 = FactoryGirl.create(:environment)
      FactoryGirl.create(:environment_class, :puppetclass => @puppetclass, :environment => env2, :puppetclass_lookup_key => @lookup_key)

      @puppetclass.destroy
      refute PuppetclassLookupKey.where(:key => @lookup_key.key).present?
    end

    test "deleting only environment a smart class parameters is in should delete the parameter" do
      @env1.destroy
      refute PuppetclassLookupKey.where(:key => @lookup_key.key).present?
    end

    test "deleting only one environment a smart class parameters is in should not delete the parameter" do
      env2 = FactoryGirl.create(:environment)
      FactoryGirl.create(:environment_class, :puppetclass => @puppetclass, :environment => env2, :puppetclass_lookup_key => @lookup_key)

      @env1.destroy
      assert PuppetclassLookupKey.where(:key => @lookup_key.key).present?
    end
  end
end
