require 'test_helper'

class CommonParametersControllerTest < ActionController::TestCase
  test "ActiveScaffold should look for CommonParameter model" do
    assert_not_nil CommonParametersController.active_scaffold_config
    assert CommonParametersController.active_scaffold_config.model == CommonParameter
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create new common_parameter" do
    assert_difference 'CommonParameter.count' do
      post :create, { :commit => "Create", :record => {:name => "my_common_parameter", :value => "valuable"} }
    end

    assert_redirected_to common_parameters_path
  end

  test "should get edit" do
    common_parameter = CommonParameter.new :name => "my_common_parameter", :value => "valuable"
    assert common_parameter.save!

    get :edit, :id => common_parameter.id
    assert_response :success
  end

  test "should update common_parameter" do
    common_parameter = CommonParameter.new :name => "my_common_parameter", :value => "valuable"
    assert common_parameter.save!

    put :update, { :commit => "Update", :id => common_parameter.id, :record => {:name => "our_common_parameter"} }
    common_parameter = CommonParameter.find_by_id(common_parameter.id)
    assert common_parameter.name == "our_common_parameter"

    assert_redirected_to common_parameters_path
  end

  test "should destroy common_parameter" do
    common_parameter = CommonParameter.new :name => "my_common_parameter", :value => "valuable"
    assert common_parameter.save!

    assert_difference('CommonParameter.count', -1) do
      delete :destroy, :id => common_parameter.id
    end

    assert_redirected_to common_parameters_path
  end
end

