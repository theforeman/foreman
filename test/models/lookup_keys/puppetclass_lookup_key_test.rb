require 'test_helper'

class PuppetclassLookupKeyTest < ActiveSupport::TestCase
  test "should not update default value unless override is true" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key,
      :default_value => "test123")
    refute lookup_key.override
    lookup_key.default_value = '33333'
    refute lookup_key.valid?
  end

  test "default_value is only validated if omit is true" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :key_type => 'boolean',
                                    :override => true, :default_value => 'whatever', :omit => true)
    assert lookup_key.valid?
    lookup_key.omit = false
    refute lookup_key.valid?
  end

  test "should update description when override is false" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :key_type => 'string',
                                    :default_value => "test123", :description => 'description')
    refute lookup_key.override
    lookup_key.description = 'new_description'
    assert lookup_key.valid?
  end

  test "should save without changes when override is false" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :key_type => 'string',
                                    :default_value => "test123", :description => 'description')
    refute lookup_key.override
    assert lookup_key.valid?
  end

  test "should allow to uncheck override" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :key_type => 'string',
                                    :default_value => "test123", :override => true)

    lookup_key.override = false
    assert lookup_key.valid?
  end

  context "delete params with class" do
    setup do
      @env1 = FactoryBot.create(:environment)
      @puppetclass = FactoryBot.create(:puppetclass)
      @lookup_key = FactoryBot.create(:puppetclass_lookup_key, :key_type => 'string',
                                      :default_value => "test123", :override => true)
      FactoryBot.create(:environment_class, :puppetclass => @puppetclass, :environment => @env1, :puppetclass_lookup_key => @lookup_key)
    end

    test "deleting puppetclass should delete smart class parameters" do
      env2 = FactoryBot.create(:environment)
      FactoryBot.create(:environment_class, :puppetclass => @puppetclass, :environment => env2, :puppetclass_lookup_key => @lookup_key)

      @puppetclass.destroy
      refute PuppetclassLookupKey.where(:key => @lookup_key.key).present?
    end

    test "deleting only environment a smart class parameters is in should delete the parameter" do
      @env1.destroy
      refute PuppetclassLookupKey.where(:key => @lookup_key.key).present?
    end

    test "deleting only one environment a smart class parameters is in should not delete the parameter" do
      env2 = FactoryBot.create(:environment)
      FactoryBot.create(:environment_class, :puppetclass => @puppetclass, :environment => env2, :puppetclass_lookup_key => @lookup_key)

      @env1.destroy
      assert PuppetclassLookupKey.where(:key => @lookup_key.key).present?
    end
  end

  test "should have auditable_type as PuppetclassLookupKey and not LookupKey" do
    PuppetclassLookupKey.create(:key => 'test_audit_parameter', :default_value => "test123")
    assert_equal 'PuppetclassLookupKey', Audit.unscoped.last.auditable_type
  end
end
