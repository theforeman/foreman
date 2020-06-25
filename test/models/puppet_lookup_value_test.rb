require 'test_helper'

class PuppetLookupValueTest < ActiveSupport::TestCase
  let(:boolean_lookup_key) { FactoryBot.create(:puppetclass_lookup_key, :boolean, path: "hostgroup\nfqdn\nhostgroup,domain") }

  test "boolean lookup value should not allow for nil value" do
    lookup_value = LookupValue.new(value: nil, match: "hostgroup=Common", lookup_key_id: boolean_lookup_key.id)
    refute lookup_value.valid?
  end

  test "boolean lookup value should allow nil value if omit is true" do
    lookup_value = LookupValue.new(value: nil, match: "hostgroup=Common", lookup_key_id: boolean_lookup_key.id, omit: true)
    assert_valid lookup_value
  end

  test "shouldn't save with empty boolean matcher for smart class parameter" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :boolean, override: true, description: 'description')
    lookup_value = FactoryBot.build_stubbed(:lookup_value, lookup_key: lookup_key, match: "os=fake", value: '')
    refute lookup_value.valid?
  end

  context "when key is a boolean and default_value is a string" do
    let(:puppet_boolean_string) do
      FactoryBot.create(:puppetclass_lookup_key, override: true, key_type: 'boolean',
        default_value: 'whatever', omit: true)
    end
    let(:lookup_value) { LookupValue.new(value: 'abc', match: "hostgroup=Common", lookup_key_id: puppet_boolean_string.id, omit: true) }

    test "value is not validated if omit is true" do
      assert_valid lookup_value
      lookup_value.omit = false
      refute_valid lookup_value
    end
  end

  context "when key type is puppetclass lookup and value is empty" do
    let(:puppet_string_empty) do
      FactoryBot.create(:puppetclass_lookup_key, :with_override, :with_omit, path: "hostgroup\ncomment", key_type: 'string')
    end
    let(:lookup_value) { LookupValue.new(value: "", match: "hostgroup=Common", lookup_key_id: puppet_string_empty.id, omit: true) }

    test "value is validated if omit is true" do
      assert_valid lookup_value
      lookup_value.omit = false
      refute_valid lookup_value
    end
  end
end
