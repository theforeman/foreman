require 'test_helper'
require 'controllers/shared/pxe_loader_test'

class Api::V2::HostgroupsControllerTest < ActionController::TestCase
  include ::PxeLoaderTest

  def basic_attrs
    {
      :architecture_id     => Architecture.find_by_name('x86_64').id,
      :operatingsystem_id  => Operatingsystem.find_by_name('Redhat').id
    }
  end

  def valid_attrs
    { :name => 'TestHostgroup' }
  end

  def valid_attrs_with_root(extra_attrs = {})
    { :hostgroup => valid_attrs.merge(extra_attrs) }
  end

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
    assert_difference('Hostgroup.unscoped.count') do
      post :create, { :hostgroup => valid_attrs }
    end
    assert_response :created
  end

  test "should update hostgroup" do
    put :update, { :id => hostgroups(:common).to_param, :hostgroup => valid_attrs }
    assert_response :success
  end

  test "should destroy hostgroups" do
    assert_difference('Hostgroup.unscoped.count', -1) do
      delete :destroy, { :id => hostgroups(:unusual).to_param }
    end
    assert_response :success
  end

  test "should clone hostgroup" do
    assert_difference('Hostgroup.unscoped.count') do
      post :clone, { :id => hostgroups(:common).to_param, :name => Time.now.utc.to_s }
    end
    assert_response :success
  end

  test "blocks API deletion of hosts with children" do
    assert hostgroups(:parent).has_children?
    assert_no_difference('Hostgroup.unscoped.count') do
      delete :destroy, { :id => hostgroups(:parent).to_param }
    end
    assert_response :conflict
  end

  test "should create nested hostgroup with a parent" do
    assert_difference('Hostgroup.unscoped.count') do
      post :create, { :hostgroup => valid_attrs.merge(:parent_id => hostgroups(:common).id) }
    end
    assert_response :success
    assert_equal hostgroups(:common).id.to_s, last_record.ancestry
  end

  test "should update a hostgroup to nested by passing parent_id" do
    put :update, { :id => hostgroups(:db).to_param, :hostgroup => {:parent_id => hostgroups(:common).id} }
    assert_response :success
    assert_equal hostgroups(:common).id.to_s,
      Hostgroup.unscoped.find_by_name("db").ancestry
  end

  test "user without view_params permission can't see hostgroup parameters" do
    setup_user "view", "hostgroups"
    hostgroup_with_parameter = FactoryGirl.create(:hostgroup, :with_parameter)
    get :show, {:id => hostgroup_with_parameter.to_param, :format => 'json'}
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see hostgroup parameters" do
    setup_user "view", "hostgroups"
    setup_user "view", "params"
    hostgroup_with_parameter = FactoryGirl.create(:hostgroup, :with_parameter)
    get :show, {:id => hostgroup_with_parameter.to_param, :format => 'json'}
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  private

  def last_record
    Hostgroup.unscoped.order(:id).last
  end
end
