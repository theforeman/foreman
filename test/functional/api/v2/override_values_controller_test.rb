require 'test_helper'

class Api::V2::OverrideValuesControllerTest < ActionController::TestCase
  smart_variable_attrs = { :match => 'xyz=10', :value => 'string' }
  smart_class_attrs = { :match => 'host=abc.com', :value => 'liftoff' }

  test "should get override values for specific smart variable" do
    get :index, {:smart_variable_id => lookup_keys(:two).to_param }
    assert_response :success
    override_values = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty override_values
    assert_equal 1, override_values["results"].length
  end
  test "should get override values for specific smart class parameter" do
    get :index, {:smart_class_parameter_id => lookup_keys(:complex).to_param }
    assert_response :success
    override_values = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty override_values
    assert_equal 2, override_values["results"].length
  end

  test 'should mark override on creation' do
    k = FactoryGirl.create(:lookup_key, :puppetclass => puppetclasses(:two))
    refute k.override
    post :create,  {:smart_variable_id => k.id, :override_value => smart_variable_attrs }
    k.reload
    assert k.override
  end

  test "should create override values for specific smart variable" do
    assert_difference('LookupValue.count') do
      post :create,  {:smart_variable_id => lookup_keys(:four).to_param, :override_value => smart_variable_attrs }
    end
    assert_response :success
  end

  test "should create override values for specific smart class parameter" do
    assert_difference('LookupValue.count') do
      post :create,  {:smart_class_parameter_id => lookup_keys(:complex).to_param, :override_value => smart_class_attrs }
    end
    assert_response :created
  end

  test "should show specific override values for specific smart variable" do
    get :show,  {:smart_variable_id => lookup_keys(:two).to_param, :id => lookup_values(:four).to_param }
    assert_response :success
    results = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty results
    assert_equal "hostgroup=Common", results['match']
  end
  test "should show specific override values for specific smart class parameter" do
    get :show,  {:smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).to_param }
    results = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty results
    assert_equal "hostgroup=Common", results['match']
    assert_response :success
  end

  test "should update specific override value" do
    put :update, { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).to_param, :override_value => { :match => 'host=abc.com' } }
    assert_response :success
  end

  test "should destroy specific override value" do
    assert_difference('LookupValue.count', -1) do
      delete :destroy, { :smart_class_parameter_id => lookup_keys(:complex).to_param, :id => lookup_values(:hostgroupcommon).to_param, :override_value => { :match => 'host=abc.com' } }
    end
    assert_response :success
  end

  [{ :value => 'xyz=10'}, { :match => 'os=string'}].each do |override_value|
    test "should not create override value without #{override_value.keys.first}" do
      lookup_key = FactoryGirl.create(:lookup_key, :puppetclass => puppetclasses(:two))
      refute lookup_key.override
      assert_difference('LookupValue.count', 0) do
        post :create, { :smart_variable_id => lookup_key.id, :override_value => override_value }
      end
      response = ActiveSupport::JSON.decode(@response.body)
      param_not_posted = override_value.keys.first.to_s == 'match' ? 'Value' : 'Match' # The opposite of override_value is missing
      assert_match /Validation failed: #{param_not_posted} can't be blank/, response['error']['message']
      assert_response :error
    end
  end
end
