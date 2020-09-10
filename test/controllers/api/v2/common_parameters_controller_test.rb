require 'test_helper'

class Api::V2::CommonParametersControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'special_key', :value => '123' }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:common_parameters)
    common_parameters = ActiveSupport::JSON.decode(@response.body)
    assert !common_parameters.empty?
  end

  test "should show parameter" do
    get :show, params: { :id => parameters(:common).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create common_parameter" do
    assert_difference('CommonParameter.count') do
      post :create, params: { :common_parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should create common parameter with lone taxonomies" do
    Location.stubs(:one?).returns(true)
    assert_difference('CommonParameter.count') do
      post :create, params: { :common_parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should update common_parameter" do
    put :update, params: { :id => parameters(:common).to_param, :common_parameter => valid_attrs }
    assert_response :success
  end

  test "should destroy common_parameter" do
    assert_difference('CommonParameter.count', -1) do
      delete :destroy, params: { :id => parameters(:common).to_param }
    end
    assert_response :success
  end

  context 'hidden' do
    test "should show a common parameter as hidden unless show_hidden is true" do
      parameter = FactoryBot.create(:common_parameter, :hidden_value => true)
      get :show, params: { :id => parameter.to_param }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['value']
    end

    test "should show a common parameter unhidden when show_hidden is true" do
      parameter = FactoryBot.create(:common_parameter, :hidden_value => true, :value => 'test')
      setup_user 'view', 'params'
      setup_user 'edit', 'params'
      get :show, params: { :id => parameter.to_param, :show_hidden => 'true' }, session: set_session_user(:one)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.value, show_response['value']
    end

    test "should show a common parameter as hidden even when show_hidden is true if user is not authorized" do
      parameter = FactoryBot.create(:common_parameter, :hidden_value => true)
      setup_user 'view', 'params'
      get :show, params: { :id => parameter.to_param, :show_hidden => 'true' }, session: set_session_user(:one)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['value']
    end
  end
end
