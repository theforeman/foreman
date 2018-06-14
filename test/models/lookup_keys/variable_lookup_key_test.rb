require 'test_helper'

# Returns a list of smart class variable types and valid values
def valid_sc_variable_data
  [
    { sc_type: 'string', value: RFauxFactory.gen_utf8 },
    { sc_type: 'boolean', value: RFauxFactory.gen_boolean },
    { sc_type: 'integer', value: rand(1..10000) },
    # random float in range -1000..1000
    { sc_type: 'real', value: (rand * 2000) - 1000 },
    { sc_type: 'array',
      value: "[\"#{RFauxFactory.gen_utf8}\",\"#{RFauxFactory.gen_numeric_string}\",\"#{RFauxFactory.gen_html}\"]" },
    { sc_type: 'hash',
      value: "{ \"#{RFauxFactory.gen_alpha}\": \"#{RFauxFactory.gen_alpha}\" }" },
    { sc_type: 'yaml',
      value: "--- #{RFauxFactory.gen_alpha}=>#{RFauxFactory.gen_alpha} ..." },
    { sc_type: 'json',
      value: "{\"#{RFauxFactory.gen_alpha}\":\"#{RFauxFactory.gen_numeric_string}\",\"#{RFauxFactory.gen_alpha}\":\"#{RFauxFactory.gen_alphanumeric}\"}"
    }
  ]
end

# Returns a list of smart class variable type with invalid values
def invalid_sc_variable_data
  [
    { sc_type: 'boolean', value: 'not a boolean' },
    { sc_type: 'integer', value: 'not an integer' },
    { sc_type: 'real', value: 'not a float' },
    { sc_type: 'array', value: 'not a valid array in string' },
    { sc_type: 'hash', value: 'not a valid hash in string' },
    { sc_type: 'yaml', value: "{#{RFauxFactory.gen_alpha}:#{RFauxFactory.gen_alpha}}" },
    { sc_type: 'json', value: "{#{RFauxFactory.gen_alpha}:#{RFauxFactory.gen_numeric_string},#{RFauxFactory.gen_alpha}:#{RFauxFactory.gen_alphanumeric}}"}
  ]
end

class VariableLookupKeyTest < ActiveSupport::TestCase
  should validate_uniqueness_of(:key)
  should_not allow_value('with whitespace').for(:key)
  should allow_values(*valid_name_list).for(:variable)

  test "validates presence of puppetclass_id" do
    variable_lk = FactoryBot.build_stubbed(:variable_lookup_key)
    refute_valid variable_lk
    assert_equal "can't be blank", variable_lk.errors[:puppetclass_id].first
  end

  test "should have auditable_type as VariableLookupKey and not LookupKey" do
    VariableLookupKey.create(:key => 'test_audit_variable', :default_value => "test123", :puppetclass => puppetclasses(:one))
    assert_equal 'VariableLookupKey', Audit.unscoped.last.auditable_type
  end

  test "should not create smart variable with invalid variable" do
    invalid_name_list.each do |variable|
      smart_variable = FactoryBot.build(:variable_lookup_key, :variable => variable, :puppetclass_id => puppetclasses(:one).id)
      refute smart_variable.valid?, "Validation succeeded for create with invalid variable: '#{variable}' length: #{variable.length})"
      assert_includes smart_variable.errors.keys, :key
    end
  end

  test "should create smart variable with valid type and default_value" do
    valid_sc_variable_data.each do |data|
      smart_variable = FactoryBot.build(
        :variable_lookup_key,
        :variable => RFauxFactory.gen_alpha,
        :puppetclass_id => puppetclasses(:one).id,
        :variable_type => data[:sc_type],
        :default_value => data[:value]
      )
      assert smart_variable.valid?
      if %w[json hash array].include? data[:sc_type]
        data_value = JSON.parse(data[:value])
      elsif data[:sc_type] == 'yaml'
        data_value = YAML.load(data[:value])
      else
        data_value = data[:value]
      end
      assert_equal data_value, smart_variable.default_value
    end
  end

  test "should not create smart variable with invalid default_value" do
    invalid_sc_variable_data.each do |data|
      smart_variable = FactoryBot.build(
        :variable_lookup_key,
        :variable => RFauxFactory.gen_alpha,
        :puppetclass_id => puppetclasses(:one).id,
        :variable_type => data[:sc_type],
        :default_value => data[:value]
      )
      refute smart_variable.valid?, "Validation succeeded for create with invalid default_value: variable_type: #{data[:sc_type]} default_value: #{data[:value]})"
      assert_includes smart_variable.errors.keys, :default_value
    end
  end

  test "should create smart variable with default value that match list validator rule" do
    values_list = [
      RFauxFactory.gen_alpha,
      RFauxFactory.gen_alphanumeric,
      rand(100..1000000),
      %w[true false].sample
    ]
    validator_rule = values_list.join(', ')
    valid_attr = {
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:two).id,
      :validator_type => 'list',
      :validator_rule => validator_rule
    }
    values_list.each do |default_value|
      smart_variable = FactoryBot.build(
        :variable_lookup_key,
        valid_attr.merge(:default_value => default_value)
      )
      assert smart_variable.valid?
      assert_equal valid_attr[:validator_type], smart_variable.validator_type
      assert_equal validator_rule, smart_variable.validator_rule
      assert_equal default_value, smart_variable.default_value
    end
  end
end
