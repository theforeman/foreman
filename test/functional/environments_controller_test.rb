require 'test_helper'

class EnvironmentsControllerTest < ActionController::TestCase
  test "ActiveScaffold should look for Environment model" do
    assert_not_nil EnvironmentsController.active_scaffold_config
    assert EnvironmentsController.active_scaffold_config.model == Environment
  end

  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
  end

  test "should create new environment" do
    assert_difference 'Environment.count' do
      post :create, { :commit => "Create", :record => {:name => "some_environment"} }, set_session_user
    end

    assert_redirected_to environments_path
  end

  test "should get edit" do
    environment = Environment.new :name => "some_environment"
    assert environment.save!

    get :edit, {:id => environment.id}, set_session_user
    assert_response :success
  end

  test "should update environment" do
    environment = Environment.new :name => "some_environment"
    assert environment.save!

    put :update, { :commit => "Update", :id => environment.id, :record => {:name => "other_environment"} }, set_session_user
    environment = Environment.find_by_id(environment.id)
    assert environment.name == "other_environment"

    assert_redirected_to environments_path
  end

  test "should destroy environment" do
    environment = Environment.new :name => "some_environment"
    assert environment.save!

    assert_difference('Environment.count', -1) do
      delete :destroy, {:id => environment.id}, set_session_user
    end

    assert_redirected_to environments_path
  end
end
