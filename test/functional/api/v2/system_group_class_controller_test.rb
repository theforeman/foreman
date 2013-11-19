require 'test_helper'

class Api::V2::SystemGroupClassesControllerTest < ActionController::TestCase

  test "should get puppetclass ids for system_group" do
    get :index, {:system_group_id => system_groups(:common).id }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
    assert_equal puppetclasses.length, 1
  end

  test "should add a puppetclass to a system_group" do
    system_group = system_groups(:common)
    assert_difference('system_group.system_group_classes.count') do
      post :create, { :system_group_id => system_group.id, :puppetclass_id => puppetclasses(:four).id }
    end
    assert_response :success
  end

  test "should remove a puppetclass from a system_group" do
    system_group = system_groups(:common)
    assert_difference('system_group.system_group_classes.count', -1) do
      delete :destroy, { :system_group_id => system_group.id, :id => puppetclasses(:one).id }
    end
    assert_response :success
  end

end