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

  context 'hidden parameters' do
    test "should show a group parameter as hidden unless show_hidden_parameters is true" do
      hostgroup = FactoryGirl.create(:hostgroup)
      hostgroup.group_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, { :id => hostgroup.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal '*****', show_response['parameters'].first['value']
    end

    test "should show a group parameter as unhidden when show_hidden_parameters is true" do
       hostgroup = FactoryGirl.create(:hostgroup)
       hostgroup.group_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
       get :show, { :id => hostgroup.id, :show_hidden_parameters => 'true' }
       show_response = ActiveSupport::JSON.decode(@response.body)
       assert_equal 'bar', show_response['parameters'].first['value']
    end
  end

  test "should update existing hostgroup parameters" do
    hostgroup = FactoryGirl.create(:hostgroup)
    param_params = { :name => "foo", :value => "bar" }
    hostgroup.group_parameters.create!(param_params)
    put :update, { :id => hostgroup.id, :hostgroup => { :group_parameters_attributes => [{ :name => param_params[:name], :value => "new_value" }] } }
    assert_response :success
    assert param_params[:name], hostgroup.parameters[param_params[:name]]
  end

  test "should delete existing hostgroup parameters" do
    hostgroup = FactoryGirl.create(:hostgroup)
    param_1 = { :name => "foo", :value => "bar" }
    param_2 = { :name => "boo", :value => "test" }
    hostgroup.group_parameters.create!([param_1, param_2])
    put :update, { :id => hostgroup.id, :hostgroup => { :group_parameters_attributes => [{ :name => param_1[:name], :value => "new_value" }] } }
    assert_response :success
    assert_equal 1, hostgroup.reload.parameters.keys.count
  end

  private

  def last_record
    Hostgroup.unscoped.order(:id).last
  end
end
