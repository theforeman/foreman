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
    get :index
    assert_response :success
    assert_not_nil assigns(:hostgroups)
    hostgroups = ActiveSupport::JSON.decode(@response.body)
    assert !hostgroups.empty?
    assert hostgroups['results'].select { |h| h.has_key?('parameters') }.empty?
  end

  test "should get index with parameters" do
    get :index, params: { :include => ['parameters'] }
    assert_response :success
    hostgroups = ActiveSupport::JSON.decode(@response.body)
    assert !hostgroups['results'].select { |h| h.has_key?('parameters') }.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => hostgroups(:common).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    assert show_response.has_key?('parameters')
  end

  test "should show all puppet clases for individual record" do
    hostgroup = FactoryBot.create(:hostgroup, :with_config_group)
    get :show, params: { :id => hostgroup.id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    assert_not_equal 0, show_response['all_puppetclasses'].length
  end

  test "should create hostgroup" do
    assert_difference('Hostgroup.unscoped.count') do
      post :create, params: { :hostgroup => valid_attrs }
    end
    assert_response :created
  end

  test "should update hostgroup" do
    put :update, params: { :id => hostgroups(:common).to_param, :hostgroup => valid_attrs }
    assert_response :success
  end

  test "should destroy hostgroups" do
    assert_difference('Hostgroup.unscoped.count', -1) do
      delete :destroy, params: { :id => hostgroups(:unusual).to_param }
    end
    assert_response :success
  end

  test "should clone hostgroup" do
    assert_difference('Hostgroup.unscoped.count') do
      post :clone, params: { :id => hostgroups(:common).to_param, :name => Time.now.utc.to_s }
    end
    assert_response :success
  end

  test "blocks API deletion of hosts with children" do
    assert hostgroups(:parent).has_children?
    assert_no_difference('Hostgroup.unscoped.count') do
      delete :destroy, params: { :id => hostgroups(:parent).to_param }
    end
    assert_response :conflict
  end

  test "should create nested hostgroup with a parent" do
    assert_difference('Hostgroup.unscoped.count') do
      post :create, params: { :hostgroup => valid_attrs.merge(:parent_id => hostgroups(:common).id) }
    end
    assert_response :success
    assert_equal hostgroups(:common).id.to_s, last_record.ancestry
  end

  test "should update a hostgroup to nested by passing parent_id" do
    put :update, params: { :id => hostgroups(:db).to_param, :hostgroup => {:parent_id => hostgroups(:common).id} }
    assert_response :success
    assert_equal hostgroups(:common).id.to_s,
      Hostgroup.unscoped.find_by_name("db").ancestry
  end

  test "user without view_params permission can't see hostgroup parameters" do
    hostgroup_with_parameter = FactoryBot.create(:hostgroup, :with_parameter)
    setup_user "view", "hostgroups"
    get :show, params: { :id => hostgroup_with_parameter.to_param, :format => 'json' }
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see hostgroup parameters" do
    hostgroup_with_parameter = FactoryBot.create(:hostgroup, :with_parameter)
    setup_user "view", "hostgroups"
    setup_user "view", "params"
    get :show, params: { :id => hostgroup_with_parameter.to_param, :format => 'json' }
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  context 'hidden parameters' do
    test "should show a group parameter as hidden unless show_hidden_parameters is true" do
      hostgroup = FactoryBot.create(:hostgroup)
      hostgroup.group_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => hostgroup.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal '*****', show_response['parameters'].first['value']
    end

    test "should show a group parameter as unhidden when show_hidden_parameters is true" do
       hostgroup = FactoryBot.create(:hostgroup)
       hostgroup.group_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
       get :show, params: { :id => hostgroup.id, :show_hidden_parameters => 'true' }
       show_response = ActiveSupport::JSON.decode(@response.body)
       assert_equal 'bar', show_response['parameters'].first['value']
    end
  end

  test "should update existing hostgroup parameters" do
    hostgroup = FactoryBot.create(:hostgroup)
    param_params = { :name => "foo", :value => "bar" }
    hostgroup.group_parameters.create!(param_params)
    put :update, params: { :id => hostgroup.id, :hostgroup => { :group_parameters_attributes => [{ :name => param_params[:name], :value => "new_value" }] } }
    assert_response :success
    assert param_params[:name], hostgroup.parameters[param_params[:name]]
  end

  test "should delete existing hostgroup parameters" do
    hostgroup = FactoryBot.create(:hostgroup)
    param_1 = { :name => "foo", :value => "bar" }
    param_2 = { :name => "boo", :value => "test" }
    hostgroup.group_parameters.create!([param_1, param_2])
    put :update, params: { :id => hostgroup.id, :hostgroup => { :group_parameters_attributes => [{ :name => param_1[:name], :value => "new_value" }] } }
    assert_response :success
    assert_equal 1, hostgroup.reload.parameters.keys.count
  end

  test "should successfully recreate host configs" do
    Hostgroup.any_instance.expects(:recreate_hosts_config).returns({'foo.example.com' => { "TFTP" => true, "DNS" => true, "DHCP" => true }})
    hostgroup = FactoryBot.create(:hostgroup)
    post :rebuild_config, params: { :id => hostgroup.to_param }, session: set_session_user
    assert_response :success
  end

  test "should not successfully recreate host configs" do
    Hostgroup.any_instance.expects(:recreate_hosts_config).returns({'foo.example.com' => { "TFTP" => true, "DNS" => false, "DHCP" => true }})
    hostgroup = FactoryBot.create(:hostgroup)
    post :rebuild_config, params: { :id => hostgroup.to_param }, session: set_session_user
    assert_response 422
  end

  test "should successfully recreate TFTP configs" do
    Hostgroup.any_instance.expects(:recreate_hosts_config).returns({'foo.example.com' => { "TFTP" => true}})
    hostgroup = FactoryBot.create(:hostgroup)
    post :rebuild_config, params: { :id => hostgroup.to_param, :only => ['TFTP'] }, session: set_session_user
    assert_response :success
  end

  private

  def last_record
    Hostgroup.unscoped.order(:id).last
  end
end
