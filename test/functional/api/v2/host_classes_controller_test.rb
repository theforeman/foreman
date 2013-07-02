require 'test_helper'

class Api::V2::HostClassesControllerTest < ActionController::TestCase

  test "should get puppetclass ids for host" do
    get :index, {:host_id => hosts(:one).to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
    assert_equal puppetclasses.length, 1
  end

  test "should add a puppetclass to a host" do
    host = hosts(:one)
    assert_difference('host.host_classes.count') do
      post :create, { :host_id => host.to_param, :puppetclass_id => puppetclasses(:four).id }
    end
    assert_response :success
  end

  test "should remove a puppetclass from a host" do
    host = hosts(:one)
    assert_difference('host.host_classes.count', -1) do
      delete :destroy, { :host_id => host.to_param, :id => puppetclasses(:one).id }
    end
    assert_response :success
  end

end