require 'test_helper'

class Api::V2::HostgroupsControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'TestHostgroup' }

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:hostgroups)
    hostgroups = ActiveSupport::JSON.decode(@response.body)
    assert !hostgroups.empty?
  end

  test "should show individual record" do
    get :show, { :id => hostgroups(:common).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create hostgroup" do
    assert_difference('Hostgroup.count') do
      post :create, { :hostgroup => valid_attrs }
    end
    assert_response :success
  end

  test "should update hostgroup" do
    put :update, { :id => hostgroups(:common).to_param, :hostgroup => valid_attrs }
    assert_response :success
  end

  test "should destroy hostgroups" do
    assert_difference('Hostgroup.count', -1) do
      delete :destroy, { :id => hostgroups(:unusual).to_param }
    end
    assert_response :success
  end

  test "should clone hostgroup" do
    assert_difference('Hostgroup.count') do
      post :clone, { :id => hostgroups(:common).to_param, :name => Time.now.to_s }
    end
    assert_response :success
  end

  test "blocks API deletion of hosts with children" do
    assert hostgroups(:parent).has_children?
    assert_no_difference('Hostgroup.count') do
      delete :destroy, { :id => hostgroups(:parent).to_param }
    end
    assert_response :conflict
  end

  test "should create nested hostgroup with a parent" do
    assert_difference('Hostgroup.count') do
      post :create, { :hostgroup => valid_attrs.merge(:parent_id => hostgroups(:common).id) }
    end
    assert_response :success
    assert_equal hostgroups(:common).id.to_s, Hostgroup.unscoped.order(:id).last.ancestry
  end

  test "should update a hostgroup to nested by passing parent_id" do
    put :update, { :id => hostgroups(:db).to_param, :hostgroup => {:parent_id => hostgroups(:common).id} }
    assert_response :success
    assert_equal hostgroups(:common).id.to_s, Hostgroup.find_by_name("db").ancestry
  end
end
