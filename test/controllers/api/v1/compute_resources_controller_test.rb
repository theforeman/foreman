require 'test_helper'

class Api::V1::ComputeResourcesControllerTest < ActionController::TestCase
  def setup
    Fog.mock!
  end

  def teardown
    Fog.unmock!
  end

  valid_attrs = { :name => 'special_compute', :provider => 'EC2', :region => 'eu-west-1', :user => 'user@example.com', :password => 'secret' }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:compute_resources)
    compute_resources = ActiveSupport::JSON.decode(@response.body)
    assert !compute_resources.empty?
  end

  test "should show compute_resource" do
    get :show, params: { :id => compute_resources(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create valid compute resource" do
    post :create, params: { :compute_resource => valid_attrs }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update compute resource" do
    put :update, params: { :id => compute_resources(:mycompute).to_param, :compute_resource => { :description => "new_description" } }
    assert_equal "new_description",
      ComputeResource.unscoped.find_by_name('mycompute').description
    assert_response :success
  end

  test "should destroy compute resource" do
    assert_difference('ComputeResource.unscoped.count', -1) do
      delete :destroy, params: { :id => compute_resources(:yourcompute).id }
    end
    assert_response :success
  end

  test "should get index of owned" do
    setup_user 'view', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    get :index
    assert_response :success
    assert_not_nil assigns(:compute_resources)
    compute_resources = ActiveSupport::JSON.decode(@response.body)
    ids               = compute_resources.map { |hash| hash['compute_resource']['id'] }
    assert_includes ids, compute_resources(:mycompute).id
    refute_includes ids, compute_resources(:yourcompute).id
  end

  test "should allow access to a compute resource for owner" do
    setup_user 'view', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    get :show, params: { :id => compute_resources(:mycompute).to_param }
    assert_response :success
  end

  test "should update compute resource for owner" do
    setup_user 'edit', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    put :update, params: { :id => compute_resources(:mycompute).to_param, :compute_resource => { :description => "new_description" } }
    assert_equal "new_description",
      ComputeResource.unscoped.find_by_name('mycompute').description
    assert_response :success
  end

  test "should destroy compute resource for owner" do
    assert_difference('ComputeResource.unscoped.count', -1) do
      setup_user 'destroy', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
      delete :destroy, params: { :id => compute_resources(:mycompute).id }
    end
    assert_response :success
  end

  test "should not allow access to a compute resource out of users compute resources scope" do
    setup_user 'view', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    get :show, params: { :id => compute_resources(:one).to_param }
    assert_response :not_found
  end

  test "should not update compute resource for restricted" do
    setup_user 'edit', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    put :update, params: { :id => compute_resources(:yourcompute).to_param, :compute_resource => { :description => "new_description" } }
    assert_response :not_found
  end

  test "should not destroy compute resource for restricted" do
    setup_user 'destroy', 'compute_resources', "id = #{compute_resources(:mycompute).id}"
    delete :destroy, params: { :id => compute_resources(:yourcompute).id }
    assert_response :not_found
  end
end
