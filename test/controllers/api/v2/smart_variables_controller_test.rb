require 'test_helper'

class Api::V2::SmartVariablesControllerTest < ActionController::TestCase
  test "should get all smart variables" do
    get :index
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 3, results['results'].length
  end

  test "should get smart variables for a specific host" do
    @host = FactoryGirl.create(:host,
                               :puppetclasses => [puppetclasses(:one)],
                               :environment => environments(:production))
    get :index, {:host_id => @host.to_param}
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 2, results['results'].count
    assert_equal "bool_test", results['results'][0]['variable']
  end

  test "should get smart variables for a specific hostgroup" do
    get :index, {:hostgroup_id => hostgroups(:common).to_param}
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 2, results['results'].count
    assert_equal "bool_test", results['results'][0]['variable']
  end

  test "should get smart variables for a specific puppetclass" do
    get :index, {:puppetclass_id => puppetclasses(:two).id}
    assert_response :success
    assert_not_nil assigns(:smart_variables)
    results = ActiveSupport::JSON.decode(@response.body)
    assert !results['results'].empty?
    assert_equal 1, results['results'].count
    assert_equal "special_info", results['results'][0]['variable']
  end

  test "should create a smart variable" do
    assert_difference('LookupKey.count') do
      as_admin do
        valid_attrs = { :variable => 'test_smart_variable', :puppetclass_id => puppetclasses(:one).id }
        post :create, { :smart_variable => valid_attrs }
      end
    end
    assert_response :created
  end

  test "should show specific smart variable" do
    get :show, {:id => lookup_keys(:two).to_param, :puppetclass_id => puppetclasses(:one).id}
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update smart variable" do
    orig_value = lookup_keys(:four).default.value
    put :update, { :id => lookup_keys(:four).to_param, :smart_variable => { :default_value => 'newstring' } }
    assert_response :success
    new_value = lookup_keys(:four).reload.default.value
    refute_equal orig_value, new_value
  end

  test "should destroy smart variable" do
    assert_difference('LookupKey.count', -1) do
      delete :destroy, { :id => lookup_keys(:four).to_param }
    end
    assert_response :success
  end

  context 'hidden' do
    test "should show a smart variable as hidden unless show_hidden is true" do
      parameter = FactoryGirl.create(:variable_lookup_key, :hidden_value => true, :default_attributes => { :value => 'hidden' }, :puppetclass => puppetclasses(:one))
      get :show, { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['default_value']
    end

    test "should show a smart variable unhidden when show_hidden is true" do
      setup_user "view", "puppetclasses"
      setup_user "view", "external_variables"
      setup_user "edit", "external_variables"
      parameter = FactoryGirl.create(:variable_lookup_key, :hidden_value => true, :default_attributes => { :value => 'hidden' }, :puppetclass => puppetclasses(:one))
      get :show, { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id, :show_hidden => 'true' }, set_session_user.merge(:user => users(:one).id)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.default.value, show_response['default_value']
    end

    test "should show a smart variable parameter as hidden even when show_hidden is true if user is not authorized" do
      setup_user "view", "puppetclasses"
      setup_user "view", "external_variables"
      parameter = FactoryGirl.create(:variable_lookup_key, :hidden_value => true, :default_attributes => { :value => 'hidden' }, :puppetclass => puppetclasses(:one))
      get :show, { :id => parameter.id, :puppetclass_id => puppetclasses(:one).id, :show_hidden => 'true' }, set_session_user.merge(:user => users(:one).id)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['default_value']
    end
  end
end
