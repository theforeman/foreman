require 'test_helper'

class Api::V2::SystemClassesControllerTest < ActionController::TestCase

  test "should get puppetclass ids for system" do
    get :index, {:system_id => systems(:one).to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
    assert_equal puppetclasses.length, 1
  end

  test "should add a puppetclass to a system" do
    system = systems(:one)
    assert_difference('system.system_classes.count') do
      post :create, { :system_id => system.to_param, :puppetclass_id => puppetclasses(:four).id }
    end
    assert_response :success
  end

  test "should remove a puppetclass from a system" do
    system = systems(:one)
    assert_difference('system.system_classes.count', -1) do
      delete :destroy, { :system_id => system.to_param, :id => puppetclasses(:one).id }
    end
    assert_response :success
  end

end