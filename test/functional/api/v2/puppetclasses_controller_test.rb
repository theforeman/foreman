require 'test_helper'

class Api::V2::PuppetclassesControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'test_puppetclass' }

  test "should get index" do
    get :index, { }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
  end

  test "should create puppetclass" do
    assert_difference('Puppetclass.count') do
      post :create, { :puppetclass => valid_attrs }
    end
    assert_response :success
  end

  test "should update puppetclass" do
    put :update, { :id => puppetclasses(:one).to_param, :puppetclass => { } }
    assert_response :success
  end

  test "should destroy puppetclasss" do
    SystemClass.delete_all
    SystemGroupClass.delete_all
    assert_difference('Puppetclass.count', -1) do
      delete :destroy, { :id => puppetclasses(:one).to_param }
    end
    assert_response :success
  end

  test "should get puppetclasses for given system only" do
    get :index, {:system_id => systems(:one).to_param }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)
    assert !fact_values.empty?
  end

  test "should not get puppetclasses for nonexistent system" do
    get :index, {"search" => "system = imaginarysystem.nodomain.what" }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)
    assert fact_values.empty?
  end

  test "should get puppetclasses for system" do
    get :index, {:system_id => systems(:one).to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
    assert_equal 1, puppetclasses.length
  end

  test "should get puppetclasses for system_group" do
    get :index, {:system_group_id => system_groups(:common).to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
    assert_equal 1, puppetclasses.length
  end

  test "should get puppetclasses for environment" do
    get :index, {:environment_id => environments(:production).to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
    assert_equal 3, puppetclasses.length
  end

  test "should show puppetclass for system" do
    get :show, { :system_id => systems(:one).to_param, :id => puppetclasses(:one).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show puppetclass for system_group" do
    get :show, { :system_group_id => system_groups(:common).to_param, :id => puppetclasses(:one).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show puppetclass for environment" do
    get :show, { :environment_id => environments(:production), :id => puppetclasses(:one).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  # CRUD actions - same test as V1
  test "should get index" do
    get :index, { }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
  end

  # FYI - show puppetclass doesn't work in V1
  test "should show puppetclass with no nesting" do
    get :show, { :id => puppetclasses(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create puppetclass" do
    assert_difference('Puppetclass.count') do
      post :create, { :puppetclass => valid_attrs }
    end
    assert_response :success
  end

  test "should update puppetclass" do
    put :update, { :id => puppetclasses(:one).to_param, :puppetclass => { } }
    assert_response :success
  end

  test "should destroy puppetclasss" do
    SystemClass.delete_all
    SystemGroupClass.delete_all
    assert_difference('Puppetclass.count', -1) do
      delete :destroy, { :id => puppetclasses(:one).to_param }
    end
    assert_response :success
  end

end