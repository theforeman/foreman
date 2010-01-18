require 'test_helper'

class EnvironmentsControllerTest < ActionController::TestCase
  test "ActiveScaffold should look for Environment model" do
    assert_not_nil EnvironmentsController.active_scaffold_config
    assert EnvironmentsController.active_scaffold_config.model == Environment
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "shuold get new" do
    get :new
    assert_response :success
  end

  test "should create new environment" do
    assert_difference 'Environment.count' do
      post :create, { :commit => "Create", :record => {:name => "some_environment"} }
    end

    assert_redirected_to environments_path
  end

  test "should get edit" do
    environment = Environment.new :name => "i386"
    assert environment.save!

    get :edit, :id => environment.id
    assert_response :success
  end

  test "should update environment" do
    environment = Environment.new :name => "i386"
    assert environment.save!

    put :update, { :commit => "Update", :id => environment.id, :record => {:name => "other_environment"} }
    environment = Environment.find_by_id(environment.id)
    assert environment.name == "other_environment"

    assert_redirected_to environments_path
  end

  test "should destroy environment" do
    environment = Environment.new :name => "i386"
    assert environment.save!

    assert_difference('Environment.count', -1) do
      delete :destroy, :id => environment.id
    end

    assert_redirected_to environments_path
  end
end
