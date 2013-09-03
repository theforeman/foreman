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
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:compute_resources)
    compute_resources = ActiveSupport::JSON.decode(@response.body)
    assert !compute_resources.empty?
  end

  test "should show compute_resource" do
    get :show, { :id => compute_resources(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create valid compute resource" do
    post :create, { :compute_resource => valid_attrs }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update compute resource" do
    put :update, { :id => compute_resources(:mycompute).to_param, :compute_resource => { :description => "new_description" } }
    assert_equal "new_description", ComputeResource.find_by_name('mycompute').description
    assert_response :success
  end

  test "should destroy compute resource" do
    assert_difference('ComputeResource.count', -1) do
      delete :destroy, { :id => compute_resources(:yourcompute).id }
    end
    assert_response :success
  end

  def use_restricted_user
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(users(:restricted).login, "secret")
  end

  test "should get index of owned" do
    use_restricted_user
    get :index, {}

    assert_response :success
    assert_not_nil assigns(:compute_resources)
    compute_resources = ActiveSupport::JSON.decode(@response.body)
    ids               = compute_resources.map { |hash| hash['compute_resource']['id'] }
    assert !ids.include?(compute_resources(:mycompute).id)
    assert ids.include?(compute_resources(:yourcompute).id)
  end

  test "should allow access to a compute resource for owner" do
    use_restricted_user
    get :show, { :id => compute_resources(:yourcompute).to_param }

    assert_response :success
  end

  test "should update compute resource for owner" do
    use_restricted_user
    put :update, { :id => compute_resources(:yourcompute).to_param, :compute_resource => { :description => "new_description" } }

    assert_equal "new_description", ComputeResource.find_by_name('yourcompute').description
    assert_response :success
  end

  test "should destroy compute resource for owner" do
    use_restricted_user
    assert_difference('ComputeResource.count', -1) do
      delete :destroy, { :id => compute_resources(:yourcompute).id }
    end
    assert_response :success
  end

  test "should not allow access to a compute resource out of users compute resources scope" do
    use_restricted_user
    get :show, { :id => compute_resources(:one).to_param }

    assert_response :not_found
  end

  test "should not update compute resource for restricted" do
    use_restricted_user
    put :update, { :id => compute_resources(:mycompute).to_param, :compute_resource => { :description => "new_description" } }

    assert_response :not_found
  end

  test "should not destroy compute resource for restricted" do
    use_restricted_user
    delete :destroy, { :id => compute_resources(:mycompute).id }
    assert_response :not_found
  end
end
