require 'test_helper'

class Api::V1::ComputeResourcesControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'special_compute', :provider => 'EC2', :url => 'eu-west1', :user => 'user@example.com', :password => 'secret' }

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

end
