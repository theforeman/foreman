require 'test_helper'

class Api::V2::OverrideValuesControllerTest < ActionController::TestCase
  smart_class_attrs = { :match => 'os=abc', :value => 'liftoff' }

  test "should get override values for specific smart class parameter" do
    get :index, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param }
    assert_response :success
    override_values = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty override_values
    assert_equal 2, override_values["results"].length
  end

  test "should create override values for specific smart class parameter" do
    assert_difference('LookupValue.count') do
      post :create, params: { :smart_class_parameter_id => lookup_keys(:complex).to_param, :override_value => smart_class_attrs }
    end
    assert_response :created
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
  end
end
