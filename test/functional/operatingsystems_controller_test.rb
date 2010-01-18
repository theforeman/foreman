require 'test_helper'

class OperatingsystemsControllerTest < ActionController::TestCase
  test "ActiveScaffold should look for Operatingsystem model" do
    assert_not_nil OperatingsystemsController.active_scaffold_config
    assert OperatingsystemsController.active_scaffold_config.model == Operatingsystem
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

  test "should create new operating system" do
    assert_difference 'Operatingsystem.count' do
      post :create, { :commit => "Create", :record => {:name => "some_operating_system", :major => "9"} }
    end

    assert_redirected_to operatingsystems_path
  end

  test "should get edit" do
    operating_system = Operatingsystem.new :name => "some_operating_system", :major => "9"
    assert operating_system.save!

    get :edit, :id => operating_system.id
    assert_response :success
  end

  test "should update operating system" do
    operating_system = Operatingsystem.new :name => "some_operating_system", :major => "9"
    assert operating_system.save!

    put :update, { :commit => "Update", :id => operating_system.id, :record => {:name => "other_operating_system", :major => "10"} }
    operating_system = Operatingsystem.find_by_id(operating_system.id)
    assert operating_system.name == "other_operating_system"
    assert operating_system.major == "10"

    assert_redirected_to operatingsystems_path
  end

  test "should destroy operating system" do
    operating_system = Operatingsystem.new :name => "some_operating_system", :major => "9"
    assert operating_system.save!

    assert_difference('Operatingsystem.count', -1) do
      delete :destroy, :id => operating_system.id
    end

    assert_redirected_to operatingsystems_path
  end
end
