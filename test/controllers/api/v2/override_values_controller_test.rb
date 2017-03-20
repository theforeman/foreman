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

  test "should create override values for specific smart variable" do
    assert_difference('LookupValue.count') do
      post :create, params: { :smart_variable_id => lookup_keys(:four).to_param, :override_value => smart_variable_attrs }
    end
    assert_response :success
  end

  test "should create override values for specific smart class parameter" do
    assert_difference('LookupValue.count') do
      post :create, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :override_value => smart_class_attrs }
    end
    assert_response :created
  end

  test "should show specific override values for specific smart variable" do
    get :show, params: { :smart_variable_id => lookup_keys(:two).to_param, :id => lookup_values(:four).to_param }
    assert_response :success
    results = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty results
    assert_equal "hostgroup=Common", results['match']
  end
  test "should show specific override values for specific smart class parameter" do
    get :show, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).to_param }
    results = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty results
    assert_equal "hostgroup=Common", results['match']
    assert_response :success
  end

  test "should update specific override value" do
    put :update, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).to_param, :override_value => { :match => 'os=abc' } }
    assert_response :success
  end

  test "should destroy specific override value" do
    assert_difference('LookupValue.count', -1) do
      delete :destroy, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).to_param, :override_value => { :match => 'host=abc.com' } }
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
      param_not_posted = override_value.keys.first.to_s == 'match' ? 'Value' : 'Match' # The opposite of override_value is missing
      assert_match /Validation failed: #{param_not_posted} can't be blank/, response['error']['message']
      assert_response :error
    end
  end

  test "should create override value without value for smart variable" do
    lookup_key = FactoryBot.create(:variable_lookup_key, :puppetclass => puppetclasses(:two))
    refute lookup_key.override
    assert_difference('LookupValue.count', 1) do
      post :create, params: { :smart_variable_id => lookup_key.id, :override_value =>  { :match => 'os=string'} }
    end
    assert_response :success
  end

  test "should create override value without when omit is true" do
    lookup_key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true, :puppetclass => puppetclasses(:two))

    assert_difference('LookupValue.count', 1) do
      post :create, params: { :smart_class_parameter_id => lookup_key.id, :override_value =>  { :match => 'os=string', :omit => true} }
    end
    assert_response :success
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

  context 'hidden' do
    test "should show a override value as hidden unless show_hidden is true" do
      lookup_key = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing),:puppetclass => puppetclasses(:one), :puppetclass_lookup_key => lookup_key)
      lookup_value = FactoryBot.create(:lookup_value, :lookup_key => lookup_key, :value => 'abc', :match => 'os=fake')
      get :show, params: { :smart_class_parameter_id => lookup_key.to_param, :id => lookup_value.to_param }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal lookup_value.hidden_value, show_response['value']
    end

    test "should show override value unhidden when show_hidden is true" do
      lookup_key = FactoryBot.create(:puppetclass_lookup_key, :hidden_value => true, :default_value => 'hidden')
      FactoryBot.create(:environment_class, :environment => environments(:testing),:puppetclass => puppetclasses(:one), :puppetclass_lookup_key => lookup_key)
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
      FactoryBot.create(:environment_class, :environment => environments(:testing),:puppetclass => puppetclasses(:one), :puppetclass_lookup_key => lookup_key)
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
