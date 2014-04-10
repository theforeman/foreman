require 'test_helper'

class Api::V2::PuppetclassesControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'test_puppetclass' }

  test "should get index" do
    get :index, { }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
    assert puppetclasses['results'].kind_of?(Hash)
  end

  test "should get index with style=list" do
    get :index, {:style => 'list' }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
    assert puppetclasses['results'].kind_of?(Array)
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
    HostClass.delete_all
    HostgroupClass.delete_all
    assert_difference('Puppetclass.count', -1) do
      delete :destroy, { :id => puppetclasses(:one).to_param }
    end
    assert_response :success
  end

  test "should get puppetclasses for given host only" do
    get :index, {:host_id => hosts(:one).to_param }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)
    assert !fact_values.empty?
  end

  test "should not get puppetclasses for nonexistent host" do
    get :index, {"search" => "host = imaginaryhost.nodomain.what" }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)
    assert fact_values['results'].empty?
  end

  test "should get puppetclasses for host" do
    get :index, {:host_id => hosts(:one).to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses['results'].empty?
    assert_equal 5, puppetclasses['results'].length
  end

  test "should get puppetclasses for hostgroup" do
    get :index, {:hostgroup_id => hostgroups(:common).to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses['results'].empty?
    assert_equal 4, puppetclasses['results'].length
  end

  test "should get puppetclasses for environment" do
    get :index, {:environment_id => environments(:production).to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses['results'].empty?
    assert_equal 7, puppetclasses['results'].length
  end

  test "should show error if optional nested environment does not exist" do
    get :index, {:environment_id => 'nonexistent' }
    assert_response 404
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert_equal "Environment not found by id 'nonexistent'", puppetclasses['message']
  end

  test "should show puppetclass for host" do
    get :show, { :host_id => hosts(:one).to_param, :id => puppetclasses(:one).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute_empty show_response
  end

  test "should show puppetclass for hostgroup" do
    get :show, { :hostgroup_id => hostgroups(:common).to_param, :id => puppetclasses(:one).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show puppetclass for environment" do
    get :show, { :environment_id => environments(:production), :id => puppetclasses(:one).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute_empty show_response
  end

  # CRUD actions - same test as V1
  test "should get index" do
    get :index, { }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    refute_empty puppetclasses
  end

  # FYI - show puppetclass doesn't work in V1
  test "should show puppetclass with no nesting" do
    get :show, { :id => puppetclasses(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute_empty show_response
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
    HostClass.delete_all
    HostgroupClass.delete_all
    assert_difference('Puppetclass.count', -1) do
      delete :destroy, { :id => puppetclasses(:one).to_param }
    end
    assert_response :success
  end

end
