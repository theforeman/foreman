require 'test_helper'

class Api::V2::HostgroupClassesControllerTest < ActionController::TestCase
  test "should get puppetclass ids for hostgroup" do
    get :index, params: { :hostgroup_id => hostgroups(:common).id }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses['results'].empty?
    assert_equal puppetclasses['results'].length, 1
  end

  test "should add a puppetclass to a hostgroup" do
    hostgroup = hostgroups(:common)
    assert_difference('hostgroup.hostgroup_classes.count') do
      post :create, params: { :hostgroup_id => hostgroup.id, :puppetclass_id => puppetclasses(:four).id }
    end
    assert_response :success
  end

  test "should remove a puppetclass from a hostgroup" do
    hostgroup = hostgroups(:common)
    assert_difference('hostgroup.hostgroup_classes.count', -1) do
      delete :destroy, params: { :hostgroup_id => hostgroup.id, :id => puppetclasses(:one).id }
    end
    assert_response :success
  end
end
