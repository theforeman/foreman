require 'test_helper'

class ArchitecturesControllerTest < ActionController::TestCase
  test "ActiveScaffold should look for Architecture model" do
    assert_not_nil ArchitecturesController.active_scaffold_config
    assert ArchitecturesController.active_scaffold_config.model == Architecture
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

  test "should create new architecture" do
    assert_difference 'Architecture.count' do
      post :create, { :commit => "Create", :record => {:name => "some_architecture"} }
    end

    assert_redirected_to architectures_path
  end

  test "should get edit" do
    architecture = Architecture.new :name => "some_architecture"
    assert architecture.save!

    get :edit, :id => architecture.id
    assert_response :success
  end

  test "should update architecture" do
    architecture = Architecture.new :name => "some_architecture"
    assert architecture.save!

    put :update, { :commit => "Update", :id => architecture.id, :record => {:name => "other_architecture"} }
    architecture = Architecture.find_by_id(architecture.id)
    assert architecture.name == "other_architecture"

    assert_redirected_to architectures_path
  end

  test "should destroy architecture" do
    architecture = Architecture.new :name => "some_architecture"
    assert architecture.save!

    assert_difference('Architecture.count', -1) do
      delete :destroy, :id => architecture.id
    end

    assert_redirected_to architectures_path
  end
end
