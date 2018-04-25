require 'test_helper'

class Api::V2::OverrideValuesControllerTest < ActionController::TestCase
  smart_variable_attrs = { :match => 'xyz=10', :value => 'string' }
  smart_class_attrs = { :match => 'os=abc', :value => 'liftoff' }

  test "should get override values for specific smart variable" do
    get :index, params: { :smart_variable_id => lookup_keys(:two).to_param }
    assert_response :success
    override_values = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty override_values
    assert_equal 1, override_values["results"].length
  end
  test "should get override values for specific smart class parameter" do
    get :index, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param }
    assert_response :success
    override_values = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty override_values
    assert_equal 2, override_values["results"].length
  end

  test 'should mark override on creation' do
    k = FactoryBot.create(:variable_lookup_key, :puppetclass => puppetclasses(:two), :path => "xyz")
    refute k.override
    post :create, params: { :smart_variable_id => k.id, :override_value => smart_variable_attrs }
    k.reload
    assert k.override
  end

  test_attributes :pid => 'f0b3d51a-cf9a-4b43-9567-eb12cd973299'
  test "should create override values for specific smart variable" do
    smart_variable = lookup_keys(:four)
    unless smart_variable.override_values.empty?
      refute_includes smart_variable.override_values.map { |override_value| override_value['match']}, smart_variable_attrs[:match]
      refute_includes smart_variable.override_values.map { |override_value| override_value['value']}, smart_variable_attrs[:value]
    end
    assert_difference('LookupValue.count') do
      post :create, params: { :smart_variable_id => smart_variable.to_param, :override_value => smart_variable_attrs }
    end
    assert_response :success
    smart_variable.reload
    refute smart_variable.override_values.empty?
    assert_includes smart_variable.override_values.map { |override_value| override_value['match']}, smart_variable_attrs[:match]
    assert_includes smart_variable.override_values.map { |override_value| override_value['value']}, smart_variable_attrs[:value]
  end

  test_attributes :pid => '23b16e7f-0626-467e-b53b-35e1634cc30d'
  test "should not create override values for smart variable with non existing attribute" do
    match = 'hostgroup=nonexistingHG'
    smart_variable = lookup_keys(:four)
    assert_difference('LookupValue.count', 0) do
      post :create, params: {
        :smart_variable_id => smart_variable.to_param,
        :override_value => { :match => match, :value => RFauxFactory.gen_alpha }
      }
    end
    assert_response :error
    assert_includes @response.body, "Validation failed: Match #{match} does not match an existing host group"
    refute_includes smart_variable.override_values.map { |override_value| override_value['match']}, match
  end

  test_attributes :pid => 'a90b5bcd-f76c-4663-bf41-2f96e7e15c0f'
  test "should create override value for smart variable with match and empty value" do
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :variable_type => 'string',
      :override_value_order => 'is_virtual'
    )
    assert_difference('LookupValue.count') do
      post :create, params: {
        :smart_variable_id => smart_variable.id,
        :override_value => { :match => 'is_virtual=true', :value => '' }
      }
    end
    assert_response :success
    smart_variable.reload
    assert_equal 1, smart_variable.override_values.length
    assert_equal 'is_virtual=true', smart_variable.override_values[0]['match']
    assert_equal '', smart_variable.override_values[0]['value']
  end

  test_attributes :pid => 'ad24999f-1bed-4abb-a01f-3cb485d67968'
  test "should not create override value for smart variable with match and empty value" do
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :variable_type => 'integer',
      :override_value_order => 'is_virtual',
      :default_value => RFauxFactory.gen_numeric_string
    )
    assert_difference('LookupValue.count', 0) do
      post :create, params: {
        :smart_variable_id => smart_variable.id,
        :override_value => { :match => 'is_virtual=true', :value => '' }
      }
    end
    assert_response :error
    assert_includes @response.body, 'Validation failed: Value is invalid integer'
  end

  test_attributes :pid => '625e3221-237d-4440-ab71-6d98cff67713'
  test "should not create override value for smart variable with invalid match value" do
    assert_difference('LookupValue.count', 0) do
      post :create, params: {
        :smart_variable_id => lookup_keys(:four).id,
        :override_value => { :match => 'invalid_value', :value => RFauxFactory.gen_alpha }
      }
    end
    assert_response :error
    assert_includes @response.body, 'Validation failed: Match is invalid'
  end

  test_attributes :pid => '3ad09261-eb55-4758-b915-84006c9e527c'
  test "should create override value for smart variable with regex validator and matching value" do
    validator_type = 'regexp'
    validator_rule = '[0-9]'
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :validator_type => validator_type,
      :validator_rule => validator_rule,
      :default_value => RFauxFactory.gen_numeric_string
    )
    value = RFauxFactory.gen_numeric_string
    match = 'domain=example.com'
    assert_difference('LookupValue.count') do
      post :create, params: {
        :smart_variable_id => smart_variable.id,
        :override_value => { :match => match, :value => value }
      }
    end
    assert_response :created
    smart_variable.reload
    assert_equal validator_type, smart_variable.validator_type
    assert_equal validator_rule, smart_variable.validator_rule
    assert_equal 1, smart_variable.override_values.length
    assert_equal match, smart_variable.override_values[0]['match']
    assert_equal value, smart_variable.override_values[0]['value']
  end

  test_attributes :pid => '8a0f9251-7992-4d1e-bace-7e32637bf56f'
  test "should not create override value for smart variable with regex validator and non matching value" do
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :validator_type => 'regexp',
      :validator_rule => '[0-9]',
      :default_value => RFauxFactory.gen_numeric_string
    )
    assert_difference('LookupValue.count', 0) do
      post :create, params: {
        :smart_variable_id => smart_variable.id,
        :override_value => { :match => 'domain=example.com', :value => RFauxFactory.gen_alpha }
      }
    end
    assert_response :error
    assert_include @response.body, 'Validation failed: Value is invalid'
  end

  test_attributes :pid => 'f5eda535-6623-4130-bea0-97faf350a6a6'
  test "should create override value for smart variable with list validator and matching value" do
    validator_type = 'list'
    validator_rule = 'test, example, 30'
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :validator_type => validator_type,
      :validator_rule => validator_rule,
      :default_value => 'test'
    )
    value = 'example'
    match = 'domain=example.com'
    assert_difference('LookupValue.count') do
      post :create, params: {
        :smart_variable_id => smart_variable.id,
        :override_value => { :match => match, :value => value }
      }
    end
    assert_response :created
    smart_variable.reload
    assert_equal validator_type, smart_variable.validator_type
    assert_equal validator_rule, smart_variable.validator_rule
    assert_equal 1, smart_variable.override_values.length
    assert_equal match, smart_variable.override_values[0]['match']
    assert_equal value, smart_variable.override_values[0]['value']
  end

  test_attributes :pid => '0aff0fdf-5a62-49dc-abe1-b727459d030a'
  test "should not create override value for smart variable with list validator and not matching value" do
    validator_rule = 'test, example, 30'
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :validator_type => 'list',
      :validator_rule => validator_rule,
      :default_value => 'example'
    )
    value = 'not_in_list'
    assert_difference('LookupValue.count', 0) do
      post :create, params: {
        :smart_variable_id => smart_variable.id,
        :override_value => { :match => 'domain=example.com', :value => value }
      }
    end
    assert_response :error
    assert_include @response.body, "Validation failed: Value #{value} is not one of #{validator_rule}"
  end

  test_attributes :pid => '99057f05-62cb-4230-b16c-d96ca6a5ae91'
  test "should create override value for smart variable that match default_value type" do
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :default_value => true,
      :variable_type => 'boolean',
      :override_value_order => 'is_virtual'
    )
    match = 'is_virtual=true'
    assert_difference('LookupValue.count') do
      post :create, params: {
        :smart_variable_id => smart_variable.id,
        :override_value => { :match => match, :value => true }
      }
    end
    assert_response :created
    smart_variable.reload
    assert_equal 1, smart_variable.override_values.length
    assert_equal match, smart_variable.override_values[0]['match']
    assert_equal true, smart_variable.override_values[0]['value']
  end

  test_attributes :pid => '790c63d7-4e8a-4187-8566-3d85d57f9a4f'
  test "should not create override value for smart variable that do not match default_value type" do
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :default_value => true,
      :variable_type => 'boolean'
    )
    assert_difference('LookupValue.count', 0) do
      post :create, params: {
        :smart_variable_id => smart_variable.id,
        :override_value => { :match => 'domain=example.com', :value => 30 }
      }
    end
    assert_response :error
    assert_include @response.body, 'Validation failed: Value is invalid boolean"'
    smart_variable.reload
    assert_equal true, smart_variable.default_value
  end

  test_attributes :pid => '7a932a99-2bd9-43ee-bcda-2b01a389787c'
  test "should destroy smart variable override value" do
    smart_variable = FactoryBot.create(
      :variable_lookup_key,
      :variable => RFauxFactory.gen_alpha,
      :puppetclass_id => puppetclasses(:one).id,
      :override_value_order => 'is_virtual'
    )
    sv_lookup_value = FactoryBot.create(
      :lookup_value,
      :lookup_key_id => smart_variable.id,
      :match => 'is_virtual=true',
      :value => 'some_value'
    )
    delete :destroy, params: { :smart_variable_id => smart_variable.id, :id => sv_lookup_value.id }
    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) { sv_lookup_value.reload }
  end

  test "should create override values for specific smart class parameter" do
    assert_difference('LookupValue.count') do
      post :create, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :override_value => smart_class_attrs }
    end
    assert_response :created
  end

  test "should show specific override values for specific smart variable" do
    get :show, params: { :smart_variable_id => lookup_keys(:two).to_param, :id => lookup_values(:four).id }
    assert_response :success
    results = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty results
    assert_equal "hostgroup=Common", results['match']
  end
  test "should show specific override values for specific smart class parameter" do
    get :show, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).id }
    results = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty results
    assert_equal "hostgroup=Common", results['match']
    assert_response :success
  end
  test "should show specific override values using match" do
    get :show, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).match }
    results = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty results
    assert_equal "hostgroup=Common", results['match']
    assert_response :success
  end

  test "should update specific override value" do
    put :update, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).id, :override_value => { :match => 'os=abc' } }
    assert_response :success
  end
  test "should update specific override value using match" do
    put :update, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).match, :override_value => { :match => 'os=abc' } }
    assert_response :success
  end

  test "should destroy specific override value" do
    assert_difference('LookupValue.count', -1) do
      delete :destroy, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).id }
    end
    assert_response :success
  end
  test "should destroy specific override value using match" do
    assert_difference('LookupValue.count', -1) do
      delete :destroy, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).match }
    end
    assert_response :success
  end

  [{ :value => 'xyz=10'}, { :match => 'os=string'}].each do |override_value|
    test "should not create override value without #{override_value.keys.first}" do
      lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :path => "os", :puppetclass => puppetclasses(:two))
      refute lookup_key.override
      assert_difference('LookupValue.count', 0) do
        post :create, params: { :smart_class_parameter_id => lookup_key.id, :override_value => override_value }
      end
      response = ActiveSupport::JSON.decode(@response.body)
      param_not_posted = (override_value.keys.first.to_s == 'match') ? 'Value' : 'Match' # The opposite of override_value is missing
      assert_match /Validation failed: #{param_not_posted} can't be blank/, response['error']['message']
      assert_response :error
    end
  end

  test "should create override value without value for smart variable" do
    lookup_key = FactoryBot.create(:variable_lookup_key, :puppetclass => puppetclasses(:two))
    refute lookup_key.override
    assert_difference('LookupValue.count', 1) do
      post :create, params: { :smart_variable_id => lookup_key.id, :override_value => { :match => 'os=string'} }
    end
    assert_response :success
  end

  test_attributes :pid => '2b205e9c-e50c-48cd-8ebb-3b6bea09be77'
  test "should create override value without when omit is true" do
    value = RFauxFactory.gen_alpha
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :puppetclass => puppetclasses(:two))

    assert_difference('LookupValue.count', 1) do
      post :create, params: { :smart_class_parameter_id => lookup_key.id, :override_value =>  { :match => 'os=string', :value => value, :omit => true} }
    end
    assert_response :success
    lookup_key = LookupKey.unscoped.find_by_id(lookup_key.id)
    assert_equal lookup_key.override_values.first.match, 'os=string'
    assert_equal lookup_key.override_values.first.value, value
    assert_equal lookup_key.override_values.first.omit, true
  end

  test "should create override value without when use_puppet_default is true (compatibility test)" do
    Foreman::Deprecation.expects(:api_deprecation_warning).with('"use_puppet_default" was renamed to "omit"')
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :puppetclass => puppetclasses(:two))

    assert_difference('LookupValue.count', 1) do
      post :create, params: { :smart_class_parameter_id => lookup_key.id, :override_value =>  { :match => 'os=string', :use_puppet_default => true} }
    end
    assert_response :success
  end

  test "should create override value when use_puppet_default is false (compatibility test)" do
    Foreman::Deprecation.expects(:api_deprecation_warning).with('"use_puppet_default" was renamed to "omit"')
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :puppetclass => puppetclasses(:two), :omit => true)

    assert_difference('LookupValue.count', 1) do
      post :create, params: { :smart_class_parameter_id => lookup_key.id, :override_value =>  { :match => 'os=string', :use_puppet_default => false, :value => 'test_val'} }
    end
    assert_response :success
  end

  test "should not create override value without when omit is false" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :puppetclass => puppetclasses(:two))

    assert_difference('LookupValue.count', 0) do
      post :create, params: { :smart_class_parameter_id => lookup_key.id, :override_value =>  { :match => 'os=string', :omit => false} }
    end
    assert_response :error
  end

  test_attributes :pid => 'bef0e457-16be-4ca6-bc56-fa32dff55a01'
  test "should not create invalid matcher for non existing attribute" do
    assert_difference('LookupValue.count', 0) do
      post :create, params: { :smart_class_parameter_id => lookup_keys(:one).id, :override_value => { :match => 'hostgroup=nonexistingHG', :value => RFauxFactory.gen_alpha } }
    end
    assert_includes JSON.parse(response.body)['error']['message'], 'Validation failed: Match hostgroup=nonexistingHG does not match an existing host group'
  end

  test_attributes :pid => '49de2c9b-40f1-4837-8ebb-dfa40d8fcb89'
  test "should not create matcher with blank matcher value" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :required => true, :puppetclass => puppetclasses(:two))
    assert_difference('LookupValue.count', 0) do
      post :create, params: { :smart_class_parameter_id => lookup_key.id, :override_value =>  { :match => 'domain=example.com', :value => '' } }
    end
    assert_includes JSON.parse(response.body)['error']['message'], "Validation failed: Value can't be blank"
  end

  test_attributes :pid => '21668ef4-1a7a-41cb-98e3-dc4c664db351'
  test "should not create matcher with value that does not matches default type" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :default_value => true, :parameter_type => 'boolean', :puppetclass => puppetclasses(:two))
    assert_difference('LookupValue.count', 0) do
      post :create, params: { :smart_class_parameter_id => lookup_key.id, :override_value =>  { :match => 'domain=example.com', :value => RFauxFactory.gen_alpha } }
    end
    assert_includes JSON.parse(response.body)['error']['message'], 'Validation failed: Value is invalid'
  end

  test_attributes :pid => '19d319e6-9b12-485e-a680-c84d18742c40'
  test "should create matcher for attribute in parameter" do
    value = RFauxFactory.gen_alpha
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :default_value => RFauxFactory.gen_alpha, :override_value_order => 'is_virtual', :puppetclass => puppetclasses(:two))
    assert_difference('LookupValue.count') do
      post :create, params: { :smart_class_parameter_id => lookup_key.id, :override_value =>  { :match => 'is_virtual=true', :value => value } }
    end
    lookup_key = LookupKey.unscoped.find_by_id(lookup_key.id)
    assert_equal lookup_key.override_values.first.match, 'is_virtual=true'
    assert_equal lookup_key.override_values.first.value, value
  end

  context 'hidden' do
    test "should show a override value as hidden unless show_hidden is true" do
      lookup_key = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing), :puppetclass => puppetclasses(:one), :puppetclass_lookup_key => lookup_key)
      lookup_value = FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => 'abc', :match => 'os=fake')
      get :show, params: { :smart_class_parameter_id => lookup_key.to_param, :id => lookup_value.to_param }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal lookup_value.hidden_value, show_response['value']
    end

    test "should show override value unhidden when show_hidden is true" do
      lookup_key = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing), :puppetclass => puppetclasses(:one), :puppetclass_lookup_key => lookup_key)
      lookup_value = FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => 'abc', :match => 'os=fake')
      setup_user "view", "puppetclasses"
      setup_user "view", "external_parameters"
      setup_user "edit", "external_parameters"
      get :show, params: { :smart_class_parameter_id => lookup_key.to_param, :id => lookup_value.to_param, :show_hidden => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal lookup_value.value, show_response['value']
    end

    test "should show a override value parameter as hidden when user in unauthorized for smart class variable" do
      lookup_key = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing), :puppetclass => puppetclasses(:one), :puppetclass_lookup_key => lookup_key)
      lookup_value = FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => 'abc', :match => 'os=fake')
      setup_user "view", "puppetclasses"
      setup_user "view", "external_parameters"
      setup_user "edit", "external_variables"
      get :show, params: { :smart_class_parameter_id => lookup_key.to_param, :id => lookup_value.to_param, :show_hidden => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal lookup_value.hidden_value, show_response['value']
    end

    test "should show a override value parameter as hidden when user in unauthorized for smart class parameter" do
      lookup_key = FactoryBot.create(:variable_lookup_key, :hidden_value => true, :default_value => 'hidden', :puppetclass => puppetclasses(:one))
      lookup_value = FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => 'abc', :match => 'os=fake')
      setup_user "view", "puppetclasses"
      setup_user "view", "external_variables"
      setup_user "view", "external_parameters"
      get :show, params: { :smart_variable_id => lookup_key.to_param, :id => lookup_value.to_param, :show_hidden => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal lookup_value.hidden_value, show_response['value']
    end
  end
end
